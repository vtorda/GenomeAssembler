#!/bin/bash
echo "Pilon is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Trimmomatic_files=$(grep Trimmo ${Out}/All_raw_scaffolds.fasta)
Lighter_files=$(grep Lighter ${Out}/All_raw_scaffolds.fasta)

OutputDir=$Out/Polished_genomes_POLCA
mkdir -p $OutputDir
# create a folder where the polished genomes are gathered
mkdir -p $OutputDir/Polished_genomes_final
lighter1=$(ls -d $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz)
lighter2=$(ls -d $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz)
#mem=$(($Abyss_mem / ${Threads}))
# lighter
for scaffold in $Lighter_files; do
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}/samtools1
	#source activate busco_env
	#bwa index $scaffold && bwa mem -t $Threads $scaffold $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz | \
	#samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	#samtools markdup -@ ${Threads} - $OutputDir/${name}/samtools1/${name}_mapped_sorted.bam && samtools index $OutputDir/${name}/samtools1/${name}_mapped_sorted.bam
	#samtools flagstat $OutputDir/${name}/samtools1/${name}_mapped_sorted.bam > $OutputDir/${name}/samtools1/${name}_mapped_sorted.stat
	#pilon -Xmx32G --changes --fix all --threads ${Threads} --genome $scaffold --frags $OutputDir/${name}/${name}_mapped_sorted.bam --output $OutputDir/${name}/${name}_polished > $OutputDir/${name}/${name}_POLCA.log 2> $OutputDir/${name}/${name}_POLCA.elog
	#conda deactivate 
	cd $OutputDir/${name}
	source activate masurca
	polca.sh -a $scaffold -r "$lighter1 $lighter2" -t ${Threads} -m 1G > $OutputDir/${name}/${name}_POLCA.log 2> $OutputDir/${name}/${name}_POLCA.elog
	conda deactivate
	#seqtk seq -L 200 $OutputDir/${name}/${name}_polished.fasta > $OutputDir/${name}/${name}_polished_filtered.fasta
	# copy final genomes to a new folder 
	#cp $OutputDir/${name}/${name}_polished_filtered.fasta $OutputDir/Polished_genomes_final/
	
done
