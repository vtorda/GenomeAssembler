#!/bin/sh
echo "FastQC is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Input=$1
Folder=$(echo $Input | awk -F '/' '{print $NF}')
OutputDir=$Out/FastQC_${FILE_base}/${Folder}
mkdir -p $OutputDir
FILES=$Input/${FILE_base}*.fastq.gz
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done