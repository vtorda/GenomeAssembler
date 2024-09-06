#!/bin/bash
source ~/.bashrc
Out=$PATH_Output/$FILE_base
OutputDir=$Out/BestAssembly
#!/bin/bash
# I need to decide if the best assembly trimmomatic or Lighter
# then  run pilon and nextpolis, probably pilon should be run with full capacity then a fast nextpolish, and the and seqtk should sort out short contigs. Then masking should be done. BUSCO should be checked in between steps


#check the $PilonFix  and ${round} arguments

echo "Pilon is started, time: $(date +"%T")"
scaffold=$(ls $OutputDir/*scaffolds.fa)
res=$(case "$scaffold" in *Trimmo*) echo "Trimmomatic";; "*Lighter*") echo "Lighter";; esac)
if [ $res == "Trimmomatic" ]
then
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	mkdir -p $OutputDir/Pilon
	#########
	# PILON
	#########
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/Pilon/${name}_mapped_sorted.bam && samtools index $OutputDir/Pilon/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/Pilon/${name}_mapped_sorted.bam > $OutputDir/Pilon/${name}_mapped_sorted.stat
	
	# include single ended reads too
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/Pilon/${name}_mapped_sorted_single.bam && samtools index $OutputDir/Pilon/${name}_mapped_sorted_single.bam
	pilon -Xmx32G --changes --fix $PilonFix --threads ${Threads} --genome $scaffold --frags $OutputDir/Pilon/${name}_mapped_sorted.bam  --unpaired $OutputDir/Pilon/${name}_mapped_sorted_single.bam --output $OutputDir/Pilon/${name}_Pilon  > $OutputDir/Pilon/${name}_pilon.log 2> $OutputDir/Pilon/${name}_pilon.elog
	
	###########
	# nextpolish
	###########
	read1=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz
	read2=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz
	input=$scaffold
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/NextPolish
	for ((i=1; i<=${round}; i++)); do
	#step 1:
	   #index the genome file and do alignment
	   bwa index ${input};
	   bwa mem -t ${Threads} ${input} ${read1} ${read2}|samtools view --threads 3 -F 0x4 -b -|samtools fixmate -m --threads 3  - -|samtools sort -m 2g --threads 5 -|samtools markdup --threads 5 -r - $OutputDir/NextPolish/${name}_sgs.sort.bam
	   #index bam and genome files
	   samtools index -@ ${Threads} $OutputDir/NextPolish/${name}_sgs.sort.bam;
	   samtools faidx ${input};
	   #polish genome file
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 1 -p ${Threads}  -s $OutputDir/NextPolish/${name}_sgs.sort.bam > $OutputDir/NextPolish/${name}_polished_temp.fasta;
	   input=$OutputDir/NextPolish/${name}_polished_temp.fasta;
	#step2:
	   #index genome file and do alignment
	   bwa index ${input};
	   bwa mem -t ${Threads} ${input} ${read1} ${read2}|samtools view --threads 3 -F 0x4 -b -|samtools fixmate -m --threads 3  - -|samtools sort -m 2g --threads 5 -|samtools markdup --threads 5 -r - $OutputDir/NextPolish/${name}_sgs.sort.bam
	   #index bam and genome files
	   samtools index -@ ${Threads} $OutputDir/NextPolish/${name}_sgs.sort.bam;
	   samtools faidx ${input};
	   #polish genome file
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 2 -p ${Threads}  -s $OutputDir/${name}/${name}_sgs.sort.bam > $OutputDir/${name}/${name}_polished.fasta;
	   input=$OutputDir/${name}/${name}_polished.fasta;
	done;


seqtk seq -L 200 $OutputDir/${name}/${name}_polished.fasta > $OutputDir/${name}/${name}_polished_filtered.fasta
fi

if [ $res == "Lighter" ]
then
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/Pilon
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/Pilon/${name}_mapped_sorted.bam && samtools index $OutputDir/Pilon/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/Pilon/${name}_mapped_sorted.bam > $OutputDir/Pilon/${name}_mapped_sorted.stat
	pilon -Xmx32G --changes --fix $PilonFix --threads ${Threads} --genome $scaffold --frags $OutputDir/Pilon/${name}_mapped_sorted.bam --output $OutputDir/Pilon/${name}_Pilon > $OutputDir/Pilon/${name}_pilon.log  2> $OutputDir/Pilon/${name}_pilon.elog
	


seqtk seq -L 200 $OutputDir/${name}/${name}_polished.fasta > $OutputDir/${name}/${name}_polished_filtered.fasta
fi

Trimmomatic_files=$(grep Trimmo ${Out}/All_raw_scaffolds.fasta)
Lighter_files=$(grep Lighter ${Out}/All_raw_scaffolds.fasta)

OutputDir=$Out/Polished_genomes
mkdir -p $OutputDir
# create a folder where the polished genomes are gathered
mkdir -p $OutputDir/Polished_genomes_final
mkdir -p $OutputDir/Polished_genomes_stat
# lighter
for scaffold in $Lighter_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted.bam > $OutputDir/${name}/${name}_mapped_sorted.stat
	pilon -Xmx32G --changes --fix all --threads ${Threads} --genome $scaffold --frags $OutputDir/${name}/${name}_mapped_sorted.bam --output $OutputDir/${name}/${name}_polished > $OutputDir/${name}/${name}_pilon.log --fix $PilonFix 2> $OutputDir/${name}/${name}_pilon.elog
	seqtk seq -L 200 $OutputDir/${name}/${name}_polished.fasta > $OutputDir/${name}/${name}_polished_filtered.fasta
	# copy final genomes to a new folder 
	cp $OutputDir/${name}/${name}_polished_filtered.fasta $OutputDir/Polished_genomes_final/
	
	# move all intermediate files into a new subfolder
	Polishing_files=$OutputDir/${name}/Polishing_files
	mkdir -p $Polishing_files
	mv $OutputDir/${name}/*.bam $OutputDir/${name}/*.bam.bai $OutputDir/${name}/*.stat $OutputDir/${name}/*.elog $OutputDir/${name}/*_pilon.txt $OutputDir/${name}/*.changes $Polishing_files
	
	#calculate new statistics
	genome=$(ls -d ${OutputDir}/${name}/*polished_filtered.fasta)
	name=$(echo $genome | awk -F '/' '{print $NF}')
	bwa index $genome && bwa mem -t $Threads $genome $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted_polished.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted_polished.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted_polished.bam > $OutputDir/${name}/${name}_mapped_sorted_polished.stat
	# copy stat file into one folder for multiqc
	cp $OutputDir/${name}/${name}_mapped_sorted_polished.stat $OutputDir/Polished_genomes_stat/
done

for scaffold in $Trimmomatic_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted.bam > $OutputDir/${name}/${name}_mapped_sorted.stat
	
	# include single ended reads too
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted_single.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted_single.bam
	pilon -Xmx32G --changes --fix all --threads ${Threads} --genome $scaffold --frags $OutputDir/${name}/${name}_mapped_sorted.bam  --unpaired $OutputDir/${name}/${name}_mapped_sorted_single.bam --output $OutputDir/${name}/${name}_polished --fix $PilonFix > $OutputDir/${name}/${name}_pilon.log 2> $OutputDir/${name}/${name}_pilon.elog
	seqtk seq -L 200 $OutputDir/${name}/${name}_polished.fasta > $OutputDir/${name}/${name}_polished_filtered.fasta
	# copy final genomes to a new folder 
	cp $OutputDir/${name}/${name}_polished_filtered.fasta $OutputDir/Polished_genomes_final/
	
	# move all intermediate files into a new subfolder
	Polishing_files=$OutputDir/${name}/Polishing_files
	mkdir -p $Polishing_files
	mv $OutputDir/${name}/*.bam $OutputDir/${name}/*.bam.bai $OutputDir/${name}/*.stat $OutputDir/${name}/*.elog $OutputDir/${name}/*_pilon.txt $OutputDir/${name}/*.changes $Polishing_files
	
	#calculate new statistics
	genome=$(ls -d ${OutputDir}/${name}/*polished_filtered.fasta)
	name=$(echo $genome | awk -F '/' '{print $NF}')
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted_polished.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted_polished.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted_polished.bam > $OutputDir/${name}/${name}_mapped_sorted_polished.stat
	# copy stat file into one folder for multiqc
	cp $OutputDir/${name}/${name}_mapped_sorted_polished.stat $OutputDir/Polished_genomes_stat/
done