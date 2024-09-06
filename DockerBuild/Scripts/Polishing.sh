#!/bin/bash
echo "Pilon is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Trimmomatic_files=$(grep Trimmo ${Out}/All_raw_scaffolds.fasta)
Lighter_files=$(grep Lighter ${Out}/All_raw_scaffolds.fasta)

OutputDir=$Out/Polished_genomes
mkdir -p $OutputDir
# lighter
for scaffold in $Lighter_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/${name}_mapped_sorted.bam > $OutputDir/${name}_mapped_sorted.stat
	pilon -Xmx32G --changes --fix all --threads ${Threads} --genome $scaffold --frags $OutputDir/${name}_mapped_sorted.bam --output $OutputDir/${name}_polished > $OutputDir/${name}_pilon.log 2> $OutputDir/${name}_pilon.elog
	seqtk seq -L 200 $OutputDir/${name}_polished.fasta > $OutputDir/${name}_polished_filtered.fasta
done

for scaffold in $Trimmomatic_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}_mapped_sorted.bam
	samtools flagstat $OutputDir/${name}_mapped_sorted.bam > $OutputDir/${name}_mapped_sorted.stat
	# include single ended reads too
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}_mapped_sorted_single.bam && samtools index $OutputDir/${name}_mapped_sorted_single.bam
	pilon -Xmx32G --changes --fix all --threads ${Threads} --genome $scaffold --frags $OutputDir/${name}_mapped_sorted.bam  --unpaired $OutputDir/${name}_mapped_sorted_single.bam --output $OutputDir/${name}_polished  > $OutputDir/${name}_pilon.log 2> $OutputDir/${name}_pilon.elog
	seqtk seq -L 200 $OutputDir/${name}_polished.fasta > $OutputDir/${name}_polished_filtered.fasta
done
# move all intermediate files into a new subfolder
Polishing_files=$OutputDir/Polishing_files
mkdir -p $Polishing_files
mv $OutputDir/*.bam $OutputDir/*.bam.bai $OutputDir/*.stat $OutputDir/*.elog $OutputDir/*_pilon.txt $OutputDir/*.changes $Polishing_files
# run samtools flagstat on the new genomes
all_genomes=$(ls -d ${OutputDir}/*polished_filtered*)
Trimmomatic_files=$(echo "${all_genomes[*]}" | grep Trimmo)
Lighter_files=$(echo "${all_genomes[*]}" | grep Lighter)

for scaffold in $Lighter_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}_mapped_sorted_polished.bam && samtools index $OutputDir/${name}_mapped_sorted_polished.bam
	samtools flagstat $OutputDir/${name}_mapped_sorted_polished.bam > $OutputDir/${name}_mapped_sorted_polished.stat
done

for scaffold in $Trimmomatic_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}_mapped_sorted_polished.bam && samtools index $OutputDir/${name}_mapped_sorted_polished.bam
	samtools flagstat $OutputDir/${name}_mapped_sorted_polished.bam > $OutputDir/${name}_mapped_sorted_polished.stat
done