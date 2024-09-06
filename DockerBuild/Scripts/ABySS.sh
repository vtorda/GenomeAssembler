#!/bin/sh
Out=$PATH_Output/${FILE_base}
bestk=$(cat $Out/KmerGenie_${FILE_base}/best_k.txt)
mkdir $Out/ABySS_${FILE_base}
OutputDir=$Out/ABySS_${FILE_base}/HardTrim
mkdir $OutputDir

for k in 33 50 70 90 110 120 ${bestk}
do
	echo "${input_path}GGIRW7_TrimmedPaired_1.fastq.gz"
	mkdir $OutputDir/kmer_${k}
	abyss-pe -C $OutputDir/kmer_${k} in="${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard/*TrimmedPaired_1.fastq.gz ${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard/*TrimmedPaired_2.fastq.gz" \
					se="${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard/*_TrimmedSingle_1.fastq.gz ${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard/*_TrimmedSingle_2.fastq.gz" name=${FILE_base} v=-v k=$k B=3G
done > $OutputDir/${FILE_base}_logfile.log 2> $OutputDir/${FILE_base}_logfile.elog
abyss-fac $OutputDir/kmer_*/${FILE_base}-scaffolds.fa > $OutputDir/${FILE_base}_abyss_comparison.tsv