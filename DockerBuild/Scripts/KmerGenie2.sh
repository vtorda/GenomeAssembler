#!/bin/sh
Out=$PATH_Output/$FILE_base
INPUT=$1
Pattern=$2
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
echo "Started kmergenie, time: $(date +"%T")"
mkdir -p $Out/KmerGenie_${FILE_base}
OutputDir=$Out/KmerGenie_${FILE_base}/${Folder}
mkdir -p $OutputDir
ls -1 $INPUT/${FILE_base}${Pattern}*.fastq.gz > $OutputDir/list_file
cd $OutputDir
kmergenie $OutputDir/list_file > KmerGenie.log
wait
grep "^best k" KmerGenie.log | tr -dc '0-9' > best_k.txt
grep ^`cat best_k.txt` histograms.dat | awk -F ' ' '{print $2}' > genome_size.txt
cd $Out