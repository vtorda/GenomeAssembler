#!/bin/bash
# kat crashes randomly with a memory issue (error 1) so I will catch the error and j
# following https://tecadmin.net/bash-exit-on-error/
# and https://www.tutorialspoint.com/bash-trap-command-explained
# and https://stackoverflow.com/questions/696839/how-do-i-write-a-bash-script-to-restart-a-process-if-it-dies
#
# USING TIMEOUT!! https://unix.stackexchange.com/questions/205076/timeout-function-return-value
# AND https://linuxize.com/post/timeout-command-in-linux/

echo "KAT is running, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base

InputDir=$1
if [ $Polish = 1 ]
	then
	all_genomes=$(ls -d ${InputDir}/*polished.fasta)
fi
if [ $Polish != 1 ]
	then
	all_genomes=$(ls -d ${InputDir}/*scaffolds.fa)
fi

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
	echo kat comp -t $Threads -v -o pe_vs_${assembly} $fastq/*Pair*fastq.gz $scaffold > vs_${assembly}.log 2> vs_${assembly}.elog
	status_value=124
	while [ $status_value == 124 ]
		do
		timeout -k 10 ${crashwait}m kat comp -t $Threads -v -o pe_vs_${assembly} $fastq/*Pair*fastq.gz $scaffold > vs_${assembly}.log 2> vs_${assembly}.elog
		if [ $? == 124 ] ; then
			echo vs_${assembly} crashed and RERUN
		fi
		if [ $? -ne 124 ] ; then
			echo vs_${assembly} is not crashed
			status_value=0
		fi
		done
done
fastq=${Out}/Lighter_${FILE_base} # assembly stat
for scaffold in $Lighter_files; do
	assembly=$(echo $scaffold | awk -F '/' '{print $NF}')
	echo kat comp  -t $Threads -v -o pe_vs_${assembly} $fastq/*Pair*fastq.gz $scaffold > vs_${assembly}.log 2> vs_${assembly}.elog
	status_value=124
	while [ $status_value == 124 ]
		do
		timeout -k 10 ${crashwait}m kat comp -t $Threads -v -o pe_vs_${assembly} $fastq/*Pair*fastq.gz $scaffold > vs_${assembly}.log 2> vs_${assembly}.elog
		if [ $? == 124 ] ; then
			echo vs_${assembly} crashed and RERUN
		fi
		if [ $? -ne 124 ] ; then
			echo vs_${assembly} is not crashed
			status_value=0
		fi
		done
done

cd $Out