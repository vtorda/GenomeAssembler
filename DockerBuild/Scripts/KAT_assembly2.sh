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
Assembly_path=$1
Folder=$(echo $Assembly_path | awk -F '/' '{print $NF}')
Scaffolds=$( < ${Assembly_path}/*_scaffolds_to_anal.txt)
#echo $Folder
#echo $Scaffolds
mkdir -p $Out/KAT_${FILE_base}
mkdir -p $Out/KAT_${FILE_base}/AssemblyStat
OutputDir=$Out/KAT_${FILE_base}/AssemblyStat/${Folder}
mkdir -p $OutputDir
cd $OutputDir
#echo Third $fastq
for scaffold in $Scaffolds; do
	assembly=$(echo $scaffold | awk -F '/' '{print $8}')
	#echo $scaffold
	#echo ${assembly}
	echo kat comp -o pe_vs_${assembly} $2/*fastq.gz $scaffold
	until kat comp -o pe_vs_${assembly} $2/*fastq.gz $scaffold 2>&1 | { while read -t 10 line; do echo "$line" >> log.txt; done; if [ $? -eq 0 ]; then echo "Successfull"; else pkill $!; fi; } 
	do
	echo "Restart KAT"
	sleep 2
	done
done
cd $Out