#!/bin/bash
# kat crashes randomly with a memory issue (error 1) so I will catch the error and j
# following https://tecadmin.net/bash-exit-on-error/
# and https://www.tutorialspoint.com/bash-trap-command-explained
# and https://stackoverflow.com/questions/696839/how-do-i-write-a-bash-script-to-restart-a-process-if-it-dies
set -E

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1
#handle_error() {
# echo "An error occured. Exit KAT"
# exit 1
#}
#trap handle_error SIGSEGV
trap 'if [[ $? -eq 139 ]]; then echo "segfault"; fi' EXIT
trap 'echo $?' ERR
echo "KAT is running, time: $(date +"%T")"
trap 'echo "Command exited with non-zero status"' SIGSEGV
trap 'echo "Command exited with non-zero status2"' SEGV
trap 'echo "Command exited with non-zero status2"' 11
Out=$PATH_Output/$FILE_base
mkdir -p $Out/KAT_${FILE_base}
OutputDir=$Out/KAT_${FILE_base}/ReadStat
mkdir -p $OutputDir
cd $OutputDir
# untrimmed fastq
until kat comp -n -o raw_read_comp $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat plot spectra-mx -i -o raw_read_spectra raw_read_comp-main.mx 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o raw_read_gc1 $PATH_Input/$FILE_base$FowardTail 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o raw_read_gc2 $PATH_Input/$FILE_base$ReverseTail 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o raw_read_gc_combined $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done


# adapter trimmed fastq
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters
until kat comp -n -o adapter_trim_comp $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat plot spectra-mx -i -o adapter_trim_spectra adapter_trim_comp-main.mx 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o adapter_trim_gc1 $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o adapter_trim_gc2 $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o adapter_trim_gc_combined $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done


# hard trim
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
until kat comp -n -o hard_trim_comp ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat plot spectra-mx -i -o hard_trim_spectra hard_trim_comp-main.mx 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o hard_trim_gc1 ${INPUT}/*Paired_1.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o hard_trim_gc2 ${INPUT}/*Paired_2.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o hard_trim_gc_combined ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done


#Lighter
INPUT=$Out/Lighter_${FILE_base}
until kat comp -n -o lighter_comp ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat plot spectra-mx -i -o lighter_spectra lighter_comp-main.mx 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o lighter_trim_gc1 ${INPUT}/*Pair_1*.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o lighter_trim_gc2 ${INPUT}/*Pair_2*.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done
until kat gcp -o lighter_trim_gc_combined ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
do
	echo "Restart KAT"
	sleep 2
done

cd $Out