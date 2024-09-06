#!/bin/sh
# $1 is a base name of fastq files
FILES=$PATH_Input/$1*
OutputDir=$PATH_Output/FastQC_$1
mkdir $OutputDir
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done









