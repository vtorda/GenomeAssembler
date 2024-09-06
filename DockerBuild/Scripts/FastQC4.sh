#!/bin/sh

FILES=$PATH_Input/${FILE_base}*
OutputDir=$PATH_Output/FastQC_$FILE_base
mkdir $OutputDir
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done









