#!/bin/bash
echo "Spades is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
INPUT=$1
multicell=$2
meta=$3
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
mkdir -p $Out/SPAdes_${FILE_base}
OutputDir=$Out/SPAdes_${FILE_base}/${Folder}
mkdir -p $OutputDir
if [ $multicell = 1 ]
then
	echo "Starting multicell assemler, time: $(date +"%T")"
	echo "Analysis of ${Folder} fastq libraries"
	out1=$Out/SPAdes_${FILE_base}/${Folder}/Multicell
	mkdir -p $out1
	spades.py --only-assembler --careful -t $Threads --pe1-1 ${INPUT}/*Pair_1*.fastq.gz --pe1-2 ${INPUT}/*Pair_2*.fastq.gz -o $out1 > ${out1}/Spades.log 2> ${out1}/Spades.elog
	cp ${out1}/scaffolds.fasta  ${out1}/SPAdes_${FILE_base}_${Folder}_Multicell.scaffolds.fa
	echo ${out1}/SPAdes_${FILE_base}_${Folder}_Multicell.scaffolds.fa >> $Out/SPAdes_${FILE_base}/Spades_scaffolds_to_anal.txt
fi
if [ $meta = 1 ]
then
	echo "Starting metagenomics assembler, time: $(date +"%T")"
	echo "Analysis of ${Folder} fastq libraries"
	out_meta=$Out/SPAdes_${FILE_base}/${Folder}/Meta
	mkdir -p $out_meta
	spades.py --meta --only-assembler -t $Threads --pe1-1 ${INPUT}/*Pair_1*.fastq.gz --pe1-2 ${INPUT}/*Pair_2*.fastq.gz -o $out_meta > ${out_meta}/Spades.log 2> ${out_meta}/Spades.elog
	cp ${out_meta}/scaffolds.fasta  ${out_meta}/SPAdes_${FILE_base}_${Folder}_Meta.scaffolds.fa
	echo ${out_meta}/SPAdes_${FILE_base}_${Folder}_Meta.scaffolds.fa >> $Out/SPAdes_${FILE_base}/Spades_scaffolds_to_anal.txt
fi

