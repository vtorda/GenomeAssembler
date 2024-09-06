#!/bin/bash
echo "Megahit is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
INPUT=$1
multicell=$2
meta=$3
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
KmerGenie=$Out/KmerGenie_${FILE_base}/${Folder}
bestk=$(cat $KmerGenie/best_k.txt)

mkdir -p $Out/Megahit_${FILE_base}
OutputDir=$Out/Megahit_${FILE_base}/${Folder}
mkdir -p $OutputDir
if [ $multicell = 1 ]
then
	echo "Starting multicell assembler, time: $(date +"%T")"
	echo "Analysis of ${Folder} fastq libraries"
	out1=$Out/Megahit_${FILE_base}/${Folder}/Multicell
	#mkdir -p $out1
	megahit --no-mercy --min-count 3 --k-list 31,51,71,91,99 -t $Threads -1 ${INPUT}/*Pair_1*.fastq.gz -2 ${INPUT}/*Pair_2*.fastq.gz \
	-o $out1 > $Out/Megahit_${FILE_base}/${FILE_base}_${Folder}_Multicell_logfile.log 2> $Out/Megahit_${FILE_base}/${FILE_base}_${Folder}_Multicell_logfile.elog
	cp ${out1}/final.contigs.fa  ${out1}/Megahit_${FILE_base}_${Folder}_Multicell.scaffolds.fa
	echo ${out1}/Megahit_${FILE_base}_${Folder}_Multicell.scaffolds.fa >> $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt
fi
if [ $meta = 1 ]
then
	echo "Starting metagenomic assembler, time: $(date +"%T")"
	echo "Analysis of ${Folder} fastq libraries"
	out1=$Out/Megahit_${FILE_base}/${Folder}/Meta
	#mkdir -p $out1
	megahit --min-count 2 --k-list 21,31,41,51,61,71,81,91,99 -t $Threads -1 ${INPUT}/*Pair_1*.fastq.gz -2 ${INPUT}/*Pair_2*.fastq.gz \
	-o $out1 > $Out/Megahit_${FILE_base}/${FILE_base}_${Folder}_Meta_logfile.log 2> $Out/Megahit_${FILE_base}/${FILE_base}_${Folder}_Meta_logfile.elog
	cp ${out1}/final.contigs.fa  ${out1}/Megahit_${FILE_base}_${Folder}_Meta.scaffolds.fa
	echo ${out1}/Megahit_${FILE_base}_${Folder}_Meta.scaffolds.fa >> $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt
fi

