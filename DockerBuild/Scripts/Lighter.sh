#!/bin/sh
OutputDir=$PATH_Output/Lighter_${FILE_base}
mkdir $OutputDir
java -jar $PATH_Trimm PE -threads $Threads -trimlog $OutputDir/${FILE_base}_Trimmomatic.log $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail \
			$OutputDir/${FILE_base}_AdaptRemovePair_1.fastq.gz $OutputDir/${FILE_base}_AdaptRemoveSingle_1.fastq.gz \
			$OutputDir/${FILE_base}_AdaptRemovePair_2.fastq.gz $OutputDir/${FILE_base}_AdaptRemoveSingle_2.fastq.gz \
			ILLUMINACLIP:$PATH_UtilData/$AdaptFile:2:30:10:$MinAdapter:$Keep > $OutputDir/${FILE_base}_Trim.log 2> $OutputDir/${FILE_base}_Trim.errorlog
wait
coverage=40
kmer_length=62
genome_size=50000000
c=$((7 / $coverage))
lighter -r $OutputDir/${FILE_base}_AdaptRemovePair_1.fastq.gz -r $OutputDir/${FILE_base}_AdaptRemovePair_2.fastq.gz \
			k $kmer_length $genome_size $c -t $Threads -od $OutputDir
