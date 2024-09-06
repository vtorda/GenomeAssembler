#!/bin/bash
# kat crashes randomly with a memory issue (error 1) so I will catch the error and j
# following https://tecadmin.net/bash-exit-on-error/
# and https://www.tutorialspoint.com/bash-trap-command-explained
# and https://stackoverflow.com/questions/696839/how-do-i-write-a-bash-script-to-restart-a-process-if-it-dies
set -E
handle_error() {
 echo "An error occured. Exit KAT"
 exit 1
}
trap handle_error SIGSEGV
echo "KAT is running, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
#fastq="$@"
#echo "First $fastq"
#echo "My array: ${fastq[@]}"
#echo "Number of elements in the array: ${#fastq[@]}"
#fastq=($fastq)
#IFS=" " read -a fastq <<< $fastq
echo "First2 $fastq"
echo "My array: ${fastq[@]}"
echo "Number of elements in the array: ${#fastq[@]}"
#fastq=(${fastq[@]:1})
echo "Second $fastq"
echo "My array: ${fastq[@]}"
echo "Number of elements in the array: ${#fastq[@]}"
#fastq=$(paste <(echo \'${fastq[@]}\') --delimiters '')
InputDir=$Out/Polished_genomes/Polished_genomes_final

all_genomes=$(ls -d ${InputDir}/*polished.fasta)
Trimmomatic_files=$(echo "${all_genomes[*]}" | grep Trimmo)
Lighter_files=$(echo "${all_genomes[*]}" | grep Lighter)

#Assembly_path=$1
#Folder=$(echo $Assembly_path | awk -F '/' '{print $NF}')
#Scaffolds=$( < ${Assembly_path}/*_scaffolds_to_anal.txt)
#echo $Folder
#echo $Scaffolds
mkdir -p $Out/KAT_${FILE_base}
OutputDir=$Out/KAT_${FILE_base}/AssemblyStat
mkdir -p $OutputDir
cd $OutputDir
#echo Third $fastq
fastq=${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard
for scaffold in $Trimmomatic_files; do
	assembly=$(echo $scaffold | awk -F '/' '{print $NF}')
	#echo $scaffold
	#echo ${assembly}
	echo kat comp -o pe_vs_${assembly} $2/*fastq.gz $scaffold
	echo "signal 11" > log.txt
	until ! grep -q "signal 11" log.txt
	do
	echo " " > log.txt
	kat comp -o pe_vs_${assembly} $fastq/*Pair*fastq.gz $scaffold 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; kill $(pgrep kat); }
	#echo "Restart KAT"
	grep -q "signal 11" log.txt >> grep.log
	sleep 2
	done
done
fastq=${Out}/Lighter_${FILE_base} # assembly stat
for scaffold in $Lighter_files; do
	assembly=$(echo $scaffold | awk -F '/' '{print $NF}')
	#echo $scaffold
	#echo ${assembly}
	echo kat comp -o pe_vs_${assembly} $2/*fastq.gz $scaffold
	echo "signal 11" > log.txt
	until ! grep -q "signal 11" log.txt
	do
	echo " " > log.txt
	kat comp -o pe_vs_${assembly} $fastq/*Pair*fastq.gz $scaffold 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; kill $(pgrep kat); }
	#echo "Restart KAT"
	grep -q "signal 11" log.txt >> grep.log
	sleep 2
	done
done

cd $Out