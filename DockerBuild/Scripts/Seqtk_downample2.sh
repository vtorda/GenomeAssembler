#!/bin/sh
OutputDir=$PATH_Output/Downsample2
mkdir $OutputDir
seqtk sample $PATH_Input/$FILE_base$FowardTail 0.01 | gzip > $OutputDir/${FILE_base}_downsB_1.fastq.gz
seqtk sample $PATH_Input/$FILE_base$ReverseTail 0.01 | gzip > $OutputDir/${FILE_base}_downsB_2.fastq.gz