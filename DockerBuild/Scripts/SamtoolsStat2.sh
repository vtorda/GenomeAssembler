#!/bin/bash
echo "Samtools is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Trimmomatic_files=$(grep Trimmo ${Out}/All_raw_scaffolds.fasta)
Lighter_files=$(grep Lighter ${Out}/All_raw_scaffolds.fasta)

OutputDir=$Out/RawGenomesSamtoolsStat
mkdir -p $OutputDir
# create a folder where the polished genomes are gathered
mkdir -p $OutputDir/Raw_genomes_stat
# lighter
for scaffold in $Lighter_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted.bam > $OutputDir/${name}/${name}_mapped_sorted.stat
	# copy stat file into one folder for multiqc
	cp $OutputDir/${name}/${name}_mapped_sorted.stat $OutputDir/Raw_genomes_stat/
done

for scaffold in $Trimmomatic_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted.bam > $OutputDir/${name}/${name}_mapped_sorted.stat
	# copy stat file into one folder for multiqc
	cp $OutputDir/${name}/${name}_mapped_sorted.stat $OutputDir/Raw_genomes_stat/
done