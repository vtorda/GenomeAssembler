#!/bin/sh
Out=$PATH_Output/$FILE_base
echo "Hard trimming is started, time: $(date +"%T")"
OutputDir=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
mkdir -p $OutputDir
java -jar $PATH_Trimm PE -threads $Threads -trimlog $OutputDir/${FILE_base}_Trimmomatic.log $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail \
			$OutputDir/${FILE_base}_TrimmedPaired_1.fastq.gz $OutputDir/${FILE_base}_TrimmedSingle_1.fastq.gz \
			$OutputDir/${FILE_base}_TrimmedPaired_2.fastq.gz $OutputDir/${FILE_base}_TrimmedSingle_2.fastq.gz \
			ILLUMINACLIP:$PATH_UtilData/$AdaptFile:2:30:10:$MinAdapter:$Keep \
			LEADING:$LEADING TRAILING:$TRAILING SLIDINGWINDOW:4:$SLIDINGWINDOW MINLEN:$MINLEN > $OutputDir/${FILE_base}_Trim.log 2> $OutputDir/${FILE_base}_TrimHard.errorlog