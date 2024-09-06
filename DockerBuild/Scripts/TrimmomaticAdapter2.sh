#!/bin/sh
Out=$PATH_Output/$FILE_base
echo "Adapter trimming is started, time: $(date +"%T")"
mkdir -p $Out/Trimmomatic_${FILE_base}
OutputDir=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters
mkdir -p $OutputDir
java -Xmx$TrimMem -jar $PATH_Trimm PE -threads $Threads -trimlog $OutputDir/${FILE_base}_Trimmomatic.log $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail \
			$OutputDir/${FILE_base}_AdaptRemovePair_1.fastq.gz $OutputDir/${FILE_base}_AdaptRemoveSingle_1.fastq.gz \
			$OutputDir/${FILE_base}_AdaptRemovePair_2.fastq.gz $OutputDir/${FILE_base}_AdaptRemoveSingle_2.fastq.gz \
			ILLUMINACLIP:$PATH_UtilData/$AdaptFile:2:30:10:$MinAdapter:$Keep > $OutputDir/${FILE_base}_Trim.log 2> $OutputDir/${FILE_base}_TrimAdapt.errorlog