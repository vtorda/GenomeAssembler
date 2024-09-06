#!/bin/bash
echo "Started ABySS, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
INPUT=$1
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
KmerGenie=$Out/KmerGenie_${FILE_base}/${Folder}
bestk=$(cat $KmerGenie/best_k.txt)
mkdir -p $Out/ABySS_${FILE_base}
OutputDir=$Out/ABySS_${FILE_base}/${Folder}
mkdir -p $OutputDir
#conda activate abyss
for kc in ${kc_list}; do
	for k in ${bestk} ${K_list}; do
		mkdir $OutputDir/kmer_${k}_kc_${kc}
		echo abyss-pe -C $OutputDir/kmer_${k}_kc_${kc} in="${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz" se="${INPUT}/*Single_1.fastq.gz ${INPUT}/*Single_2.fastq.gz" name=ABySS_${Folder}_${FILE_base}_kmer${k}kc${kc} v=-v k=$k kc=$kc B=$Abyss_mem j=$Threads
		abyss-pe -C $OutputDir/kmer_${k}_kc_${kc} in="${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz" \
						se="${INPUT}/*Single_1.fastq.gz ${INPUT}/*Single_2.fastq.gz" name=ABySS_${Folder}_${FILE_base}_kmer${k}kc${kc} v=-v k=$k kc=$kc B=$Abyss_mem j=$Threads
	done
done > $OutputDir/${FILE_base}_logfile.log 2> $OutputDir/${FILE_base}_logfile.elog
abyss-fac $OutputDir/kmer_*/ABySS_${Folder}_${FILE_base}_kmer*-scaffolds.fa > $OutputDir/${FILE_base}_abyss_comparison.tsv
#conda deactivate
Rscript /home/repl/Scripts/Abyss_test_eval.R $OutputDir