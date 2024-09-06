#!/bin/bash
echo "idba_ud is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
INPUT=$1
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
mkdir -p $Out/IDBA_${FILE_base}
OutputDir=$Out/IDBA_${FILE_base}/${Folder}
mkdir -p $OutputDir
# transform fq to fasta
#read1=$(ls -d ${INPUT}/*Paired_1.fastq.gz)
#read2=$(ls -d ${INPUT}/*Paired_2.fastq.gz)
gzip -d -k ${INPUT}/*Pair_1*.fastq.gz -c > ${OutputDir}/read1.fa
gzip -d -k ${INPUT}/*Pair_2*.fastq.gz -c > ${OutputDir}/read2.fa
fq2fa --merge --filter ${OutputDir}/read1.fa ${OutputDir}/read2.fa ${OutputDir}/read.fa

echo "Analysis of ${Folder} fastq libraries"
idba_ud -r ${OutputDir}/read.fa --maxk 100 --min_contig 50 --num_threads $Threads -o $OutputDir
cp ${OutputDir}/scaffold.fa  ${OutputDir}/IDBA_${FILE_base}_${Folder}.scaffolds.fa
echo ${OutputDir}/IDBA_${FILE_base}_${Folder}.scaffolds.fa >> ${Out}/IDBA_${FILE_base}/IDBA_scaffolds_to_anal.txt
rm ${OutputDir}/read1.fa ${OutputDir}/read2.fa ${OutputDir}/read.fa