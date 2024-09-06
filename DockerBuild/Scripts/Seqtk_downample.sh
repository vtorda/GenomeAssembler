#!/bin/sh
OutputDir=$PATH_Output/Downsample
mkdir $OutputDir
seqtk sample $PATH_Input/$FILE_base$FowardTail 0.1 | gzip > $OutputDir/${FILE_base}_1_downs.fastq.gz
seqtk sample $PATH_Input/$FILE_base$ReverseTail 0.1 | gzip > $OutputDir/${FILE_base}_2_downs.fastq.gz