#!/bin/bash
# kat crashes randomly with a memory issue (error 1) so I will catch the error and j
# following https://tecadmin.net/bash-exit-on-error/
# and https://www.tutorialspoint.com/bash-trap-command-explained
# and https://stackoverflow.com/questions/696839/how-do-i-write-a-bash-script-to-restart-a-process-if-it-dies
set -E

#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>log.out 2>&1
#handle_error() {
# echo "An error occured. Exit KAT"
# exit 1
#}
#trap handle_error SIGSEGV
#trap 'if [[ $? -eq 139 ]]; then echo "segfault"; fi' EXIT
#trap 'echo $?' ERR
echo "KAT is running, time: $(date +"%T")"
#trap 'echo "Command exited with non-zero status"' SIGSEGV
#trap 'echo "Command exited with non-zero status2"' SEGV
#trap 'echo "Command exited with non-zero status2"' 11
Out=$PATH_Output/$FILE_base
mkdir -p $Out/KAT_${FILE_base}
OutputDir=$Out/KAT_${FILE_base}/ReadStat
mkdir -p $OutputDir
cd $OutputDir


####
# raw ReadStat
####
	kat comp -t $Threads -v -n -o raw_read_comp $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail > raw_read_comp.log 2> raw_read_comp.elog
	if [ $? -ne 0 ] ; then
	echo raw_read_comp is crashed and RERAN
	kat comp -t $Threads -v -n -o raw_read_comp $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail > raw_read_comp.log2 2> raw_read_comp.elog2
	fi


	kat plot spectra-mx -v -i -o raw_read_spectra raw_read_comp-main.mx > raw_read_spectra.log > raw_read_spectra.elog
	if [ $? -ne 0 ] ; then
	echo raw_read_spectra is crashed and RERAN
	kat plot spectra-mx -v -i -o raw_read_spectra raw_read_comp-main.mx > raw_read_spectra.log2 > raw_read_spectra.elog2
	fi

	kat gcp -t $Threads -v -o raw_read_gc1 $PATH_Input/$FILE_base$FowardTail > raw_read_gc1.log 2> raw_read_gc1.elog
	if [ $? -ne 0 ] ; then
	echo raw_read_gc1 is crashed and RERAN
	kat gcp -t $Threads -v -o raw_read_gc1 $PATH_Input/$FILE_base$FowardTail > raw_read_gc1.log2 2> raw_read_gc1.elog2
	fi



	kat gcp -t $Threads -v -o raw_read_gc2 $PATH_Input/$FILE_base$ReverseTail > raw_read_gc2.log > raw_read_gc2.elog
	if [ $? -ne 0 ] ; then
	echo raw_read_gc2 is crashed and RERAN
	kat gcp -t $Threads -v -o raw_read_gc2 $PATH_Input/$FILE_base$ReverseTail > raw_read_gc2.log2 > raw_read_gc2.elog2
	fi



	kat gcp -t $Threads -v -o raw_read_gc_combined $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail > raw_read_gc_combined.log 2> raw_read_gc_combined.elog
	if [ $? -ne 0 ] ; then
	echo raw_read_gc_combined is crashed and RERAN
	kat gcp -t $Threads -v -o raw_read_gc_combined $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail > raw_read_gc_combined.log2 2> raw_read_gc_combined.elog2
	fi
##########################
# adapter trimmed fastq
##########################
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters


	kat comp -t $Threads -v -n -o adapter_trim_comp $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz > adapter_trim_comp.log 2> adapter_trim_comp.elog
	if [ $? -ne 0 ] ; then
	echo adapter_trim_comp is crashed and RERAN
	kat comp -t $Threads -v -n -o adapter_trim_comp $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz > adapter_trim_comp.log2 2> adapter_trim_comp.elog2
	fi


	kat plot spectra-mx -v -i -o adapter_trim_spectra adapter_trim_comp-main.mx > adapter_trim_spectra.log 2> adapter_trim_spectra.elog
	if [ $? -ne 0 ] ; then
	echo sadapter_trim_spectra is crashed and RERAN
	kat plot spectra-mx -v -i -o adapter_trim_spectra adapter_trim_comp-main.mx > adapter_trim_spectra.log2 2> adapter_trim_spectra.elog2
	fi


	kat gcp -t $Threads -v -o adapter_trim_gc1 $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz > adapter_trim_gc1.log 2> adapter_trim_gc1.elog
	if [ $? -ne 0 ] ; then
	echo adapter_trim_gc1 is crashed and RERAN
	kat gcp -t $Threads -v -o adapter_trim_gc1 $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz > adapter_trim_gc1.log2 2> adapter_trim_gc1.elog2
	fi



	kat gcp -t $Threads -v -o adapter_trim_gc2 $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz > adapter_trim_gc2.log 2> adapter_trim_gc2.elog
	if [ $? -ne 0 ] ; then
	echo adapter_trim_gc2 is crashed and RERAN
	kat gcp -t $Threads -v -o adapter_trim_gc2 $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz > adapter_trim_gc2.log2 2> adapter_trim_gc2.elog2
	fi



	kat gcp -t $Threads -v -o adapter_trim_gc_combined $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz > adapter_trim_gc_combined.log 2> adapter_trim_gc_combined.elog
	if [ $? -ne 0 ] ; then
	echo adapter_trim_gc_combined is crashed and RERAN
	kat gcp -t $Threads -v -o adapter_trim_gc_combined $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz > adapter_trim_gc_combined.log2 2> adapter_trim_gc_combined.elog2
	fi

##################
# hard trim
################
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard


	kat comp -t $Threads -v -n -o hard_trim_comp ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz > hard_trim_comp.log 2> hard_trim_comp.elog
	if [ $? -ne 0 ] ; then
	echo hard_trim_comp is crashed and RERAN
	kat comp -t $Threads -v -n -o hard_trim_comp ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz > hard_trim_comp.log2 2> hard_trim_comp.elog2
	fi


	kat plot spectra-mx -v -i -o hard_trim_spectra hard_trim_comp-main.mx > hard_trim_spectra.log > hard_trim_spectra.elog
	if [ $? -ne 0 ] ; then
	echo hard_trim_spectra is crashed and RERAN
	kat plot spectra-mx -v -i -o hard_trim_spectra hard_trim_comp-main.mx > hard_trim_spectra.log2 > hard_trim_spectra.elog2
	fi




	kat gcp -t $Threads -v -o hard_trim_gc1 ${INPUT}/*Paired_1.fastq.gz > hard_trim_gc1.log 2> hard_trim_gc1.elog
	if [ $? -ne 0 ] ; then
	echo hard_trim_gc1 is crashed and RERAN
	kat gcp -t $Threads -v -o hard_trim_gc1 ${INPUT}/*Paired_1.fastq.gz > hard_trim_gc1.log2 2> hard_trim_gc1.elog2
	fi
	
	



	kat gcp -t $Threads -v -o hard_trim_gc2 ${INPUT}/*Paired_2.fastq.gz > hard_trim_gc2.log 2> hard_trim_gc2.elog
	if [ $? -ne 0 ] ; then
	echo hard_trim_gc2 is crashed and RERAN
	kat gcp -t $Threads -v -o hard_trim_gc2 ${INPUT}/*Paired_2.fastq.gz > hard_trim_gc2.log2 2> hard_trim_gc2.elog2
	fi
	
	

	kat gcp -t $Threads -v -o hard_trim_gc_combined ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz > hard_trim_gc_combined.log 2> hard_trim_gc_combined.elog
	if [ $? -ne 0 ] ; then
	echo hard_trim_gc_combined is crashed and RERAN
	kat gcp -t $Threads -v -o hard_trim_gc_combined ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz > hard_trim_gc_combined.log2 2> hard_trim_gc_combined.elog2
	fi


#Lighter
INPUT=$Out/Lighter_${FILE_base}


	kat comp -t $Threads -v -n -o lighter_comp ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz > lighter_comp.log 2>lighter_comp.elog
	if [ $? -ne 0 ] ; then
	echo lighter_comp is crashed and RERAN
	kat comp -t $Threads -v -n -o lighter_comp ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz > lighter_comp.log2 2>lighter_comp.elog2
	fi


	kat plot spectra-mx -v -i -o lighter_spectra lighter_comp-main.mx > lighter_spectra.log 2> lighter_spectra.elog
	if [ $? -ne 0 ] ; then
	echo lighter_spectra is crashed and RERAN
	kat plot spectra-mx -v -i -o lighter_spectra lighter_comp-main.mx > lighter_spectra.log2 2> lighter_spectra.elog2
	fi



	kat gcp -t $Threads -v -o lighter_trim_gc1 ${INPUT}/*Pair_1*.fastq.gz > lighter_trim_gc1.log 2> lighter_trim_gc1.elog
	if [ $? -ne 0 ] ; then
	echo lighter_trim_gc1 is crashed and RERAN
	kat gcp -t $Threads -v -o lighter_trim_gc1 ${INPUT}/*Pair_1*.fastq.gz > lighter_trim_gc1.log2 2> lighter_trim_gc1.elog2
	fi
	


	kat gcp -t $Threads -v -o lighter_trim_gc2 ${INPUT}/*Pair_2*.fastq.gz > lighter_trim_gc2.log 2> lighter_trim_gc2.elog
	if [ $? -ne 0 ] ; then
	echo lighter_trim_gc2 is crashed and RERAN
	kat gcp -t $Threads -v -o lighter_trim_gc2 ${INPUT}/*Pair_2*.fastq.gz > lighter_trim_gc2.log2 2> lighter_trim_gc2.elog2
	fi
	
	
	kat gcp -t $Threads -v -o lighter_trim_gc_combined ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz > lighter_trim_gc_combined.log 2> lighter_trim_gc_combined.elog
	if [ $? -ne 0 ] ; then
	echo lighter_trim_gc_combined is crashed and RERAN
	kat gcp -t $Threads -v -o lighter_trim_gc_combined ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz > lighter_trim_gc_combined.log2 2> lighter_trim_gc_combined.elog2
	fi
cd $Out
