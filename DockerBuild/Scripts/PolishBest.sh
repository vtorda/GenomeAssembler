#!/bin/bash
source ~/.bashrc
source activate base
Out=$PATH_Output/$FILE_base
OutputDir=$Out/BestAssembly

round=$NextPolishRounds
#!/bin/bash
# I need to decide if the best assembly trimmomatic or Lighter
# then  run pilon and nextpolis, probably pilon should be run with full capacity then a fast nextpolish, and the and seqtk should sort out short contigs. Then masking should be done. BUSCO should be checked in between steps


# 
#create a pilon memory argument
# handle samtools memory and thread arguments

echo "Pilon is started, time: $(date +"%T")"
scaffold=$(ls $OutputDir/*scaffolds.fa)
res=$(case "$scaffold" in *Trimmo*) echo "Trimmomatic";; *Lighter*) echo "Lighter";; esac)
N50.sh $scaffold > $OutputDir/Raw_assembly_N50.stat
if [ "$res" = "Trimmomatic" ]
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
	
	N50.sh $OutputDir/Pilon/${name}_Pilon.fasta > $OutputDir/Pilon/Pilon_N50.stat
	###########
	# nextpolish
	###########
	read1=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz
	read2=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz
	input=$OutputDir/Pilon/${name}_Pilon.fasta
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
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 2 -p ${Threads}  -s $OutputDir/NextPolish/${name}_sgs.sort.bam > $OutputDir/NextPolish/${name}_NextPolished.fasta;
	   input=$OutputDir/NextPolish/${name}_NextPolished.fasta;
	done;
	N50.sh $OutputDir/NextPolish/${name}_NextPolished.fasta > $OutputDir/NextPolish/NextPolish_N50.stat

	seqtk seq -L 200 $OutputDir/NextPolish/${name}_NextPolished.fasta > $OutputDir/${name}_polished_filtered.fasta
	N50.sh $OutputDir/${name}_polished_filtered.fasta > $OutputDir/PolishedFiltered_assembly_N50.stat
fi

if [ "$res" = "Lighter" ]
then
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/Pilon
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/Pilon/${name}_mapped_sorted.bam && samtools index $OutputDir/Pilon/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/Pilon/${name}_mapped_sorted.bam > $OutputDir/Pilon/${name}_mapped_sorted.stat
	pilon -Xmx32G --changes --fix $PilonFix --threads ${Threads} --genome $scaffold --frags $OutputDir/Pilon/${name}_mapped_sorted.bam --output $OutputDir/Pilon/${name}_Pilon > $OutputDir/Pilon/${name}_pilon.log  2> $OutputDir/Pilon/${name}_pilon.elog
	

	N50.sh $OutputDir/Pilon/${name}_Pilon.fasta > $OutputDir/Pilon/Pilon_N50.stat
	
	###########
	# nextpolish
	###########
	read1=$Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz
	read2=$Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz
	input=$OutputDir/Pilon/${name}_Pilon.fasta
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
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 2 -p ${Threads}  -s $OutputDir/NextPolish/${name}_sgs.sort.bam > $OutputDir/NextPolish/${name}_NextPolished.fasta;
	   input=$OutputDir/NextPolish/${name}_NextPolished.fasta;
	done;
	N50.sh $OutputDir/NextPolish/${name}_NextPolished.fasta > $OutputDir/NextPolish/NextPolish_N50.stat

	seqtk seq -L 200 $OutputDir/NextPolish/${name}_NextPolished.fasta > $OutputDir/${name}_polished_filtered.fasta
	N50.sh $OutputDir/${name}_polished_filtered.fasta > $OutputDir/PolishedFiltered_assembly_N50.stat
fi
