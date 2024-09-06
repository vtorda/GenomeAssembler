#!/bin/bash
echo "Pilon is started, time: $(date +"%T")"

Out=$PATH_Output/$FILE_base
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