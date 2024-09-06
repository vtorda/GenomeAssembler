#!/bin/sh
Out=$PATH_Output/$FILE_base
mkdir $Out
echo "created a new folder in $(echo ${Out})"
# Trim adapters
echo "Started adapter trimming, time: $(date +"%T")"
mkdir $Out/Trimmomatic_${FILE_base}
OutputDir=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters
mkdir $OutputDir
java -jar $PATH_Trimm PE -threads $Threads -trimlog $OutputDir/${FILE_base}_Trimmomatic.log $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail \
			$OutputDir/${FILE_base}_AdaptRemovePair_1.fastq.gz $OutputDir/${FILE_base}_AdaptRemoveSingle_1.fastq.gz \
			$OutputDir/${FILE_base}_AdaptRemovePair_2.fastq.gz $OutputDir/${FILE_base}_AdaptRemoveSingle_2.fastq.gz \
			ILLUMINACLIP:$PATH_UtilData/$AdaptFile:2:30:10:$MinAdapter:$Keep > $OutputDir/${FILE_base}_Trim.log 2> $OutputDir/${FILE_base}_Trim.errorlog
wait
# hard trimming
echo "Started hard trimming, time: $(date +"%T")"
OutputDir=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
mkdir $OutputDir
java -jar $PATH_Trimm PE -threads $Threads -trimlog $OutputDir/${FILE_base}_Trimmomatic.log $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail \
			$OutputDir/${FILE_base}_TrimmedPaired_1.fastq.gz $OutputDir/${FILE_base}_TrimmedSingle_1.fastq.gz \
			$OutputDir/${FILE_base}_TrimmedPaired_2.fastq.gz $OutputDir/${FILE_base}_TrimmedSingle_2.fastq.gz \
			ILLUMINACLIP:$PATH_UtilData/$AdaptFile:2:30:10:$MinAdapter:$Keep \
			LEADING:$LEADING TRAILING:$TRAILING SLIDINGWINDOW:4:$SLIDINGWINDOW MINLEN:$MINLEN > $OutputDir/${FILE_base}_Trim.log 2> $OutputDir/${FILE_base}_Trim.errorlog
wait
# KmerGenie
echo "Started kmergenie, time: $(date +"%T")"
OutputDir=$Out/KmerGenie_${FILE_base}
mkdir $OutputDir
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters
ls -1 $INPUT/${FILE_base}_AdaptRemovePair*.fastq.gz > $OutputDir/list_file
cd $OutputDir
kmergenie $OutputDir/list_file > KmerGenie.log
wait
grep "^best k" KmerGenie.log | tr -dc '0-9' > best_k.txt
grep `cat best_k.txt` histograms.dat | awk -F ' ' '{print $2}' > genome_size.txt

# lighter
echo "Started lighter, time: $(date +"%T")"
OutputDir=$Out/Lighter_${FILE_base}
coverage=40
kmer_length=32
genome_size=$(cat $Out/KmerGenie_${FILE_base}/genome_size.txt)
c=$((7 / $coverage))
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters
lighter -r $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz -r $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz \
			-k $kmer_length $genome_size $c -t $Threads -od $OutputDir > lighter.log
			
# Fastqc
echo "Started fastqc, time: $(date +"%T")"

FastQC_path=$Out/FastQC_${FILE_base}
mkdir $FastQC_path
OutputDir=$FastQC_path/Raw_reads
mkdir $OutputDir
FILES=$PATH_Input/${FILE_base}*.fastq.gz
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done

OutputDir=$FastQC_path/AdapterFree
mkdir $OutputDir
FILES=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters/${FILE_base}*fastq.gz
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done
	
OutputDir=$FastQC_path/HardTrim
mkdir $OutputDir
FILES=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/${FILE_base}*fastq.gz
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done

OutputDir=$FastQC_path/Lighter
mkdir $OutputDir
FILES=$Out/Lighter_${FILE_base}/${FILE_base}*fastq.gz
for f in ${FILES}
	do
		fastqc $f -o $OutputDir -t $Threads
		wait
	done