#!/bin/sh
OutputDir=$PATH_Output/KmerGenie_${FILE_base}
mkdir $OutputDir
ls -1 $PATH_Input/${FILE_base}*.fastq.gz > $OutputDir/list_file
cd $OutputDir
kmergenie $OutputDir/list_file > KmerGenie.log
wait
grep "^best k" KmerGenie.log | tr -dc '0-9' > best_k.txt
grep `cat best_k.txt` histograms.dat | awk -F ' ' '{print $2}' > genome_size.txt