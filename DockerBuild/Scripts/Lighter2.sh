#!/bin/sh
OutputDir=$PATH_Output/Lighter_${FILE_base}

coverage=40
kmer_length=32
genome_size=$(cat ${PATH_Output}/KmerGenie_${FILE_base}/genome_size.txt)
c=$((7 / $coverage))
lighter -r $OutputDir/${FILE_base}_AdaptRemovePair_1.fastq.gz -r $OutputDir/${FILE_base}_AdaptRemovePair_2.fastq.gz \
			-k $kmer_length $genome_size $c -t $Threads -od $OutputDir