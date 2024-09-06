#!/bin/sh
echo "Started lighter, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
INPUT=$1
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
KmerGenie=$Out/KmerGenie_${FILE_base}/${Folder}
OutputDir=$Out/Lighter_${FILE_base}
mkdir -p $OutputDir
# calculating coverage
fastqfile=$INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz
genome_size=$(cat ${KmerGenie}/genome_size.txt)
paired=2
read_n=$(zgrep -c @ $fastqfile)
read_length=$(($(zgrep -A 1 @ $fastqfile | wc -c) / $(echo $read_n)))
coverage=$(expr `expr $paired \* $read_n \* $read_length` / $genome_size)
kmer_length=32
#c=$((7 / $coverage)) # c was not used after all because it caused a faulty behaviour of the program. 
lighter -r $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz -r $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz \
			-K $kmer_length $genome_size -t $Threads -od $OutputDir > $OutputDir/lighter.log 2> $OutputDir/lighter.log2 #-noQual $c
cd $OutputDir
rename 's/fq\.gz/fastq\.gz/g' *.fq.gz
cd $Out