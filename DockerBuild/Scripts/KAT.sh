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
kat comp -n -o raw_read_comp $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail
kat plot spectra-mx -i -o raw_read_spectra raw_read_comp-main.mx
kat gcp -o raw_read_gc1 $PATH_Input/$FILE_base$FowardTail
kat gcp -o raw_read_gc2 $PATH_Input/$FILE_base$ReverseTail
kat gcp -o raw_read_gc_combined $PATH_Input/$FILE_base$FowardTail $PATH_Input/$FILE_base$ReverseTail
# adapter trimmed fastq
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters
kat comp -n -o adapter_trim_comp $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz
kat plot spectra-mx -i -o adapter_trim_spectra adapter_trim_comp-main.mx
kat gcp -o adapter_trim_gc1 $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz
kat gcp -o adapter_trim_gc2 $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz
kat gcp -o adapter_trim_gc_combined $INPUT/${FILE_base}_AdaptRemovePair_1.fastq.gz $INPUT/${FILE_base}_AdaptRemovePair_2.fastq.gz
# hard trim
INPUT=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
kat comp -n -o hard_trim_comp ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz
kat plot spectra-mx -i -o hard_trim_spectra hard_trim_comp-main.mx
kat gcp -o hard_trim_gc1 ${INPUT}/*Paired_1.fastq.gz
kat gcp -o hard_trim_gc2 ${INPUT}/*Paired_2.fastq.gz
kat gcp -o hard_trim_gc_combined ${INPUT}/*Paired_1.fastq.gz ${INPUT}/*Paired_2.fastq.gz
#Lighter
INPUT=$Out/Lighter_${FILE_base}
kat comp -n -o lighter_comp ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz
kat plot spectra-mx -i -o lighter_spectra lighter_comp-main.mx
kat gcp -o lighter_trim_gc1 ${INPUT}/*Pair_1*.fastq.gz
kat gcp -o lighter_trim_gc2 ${INPUT}/*Pair_2*.fastq.gz
kat gcp -o lighter_trim_gc_combined ${INPUT}/*Pair_1*.fastq.gz ${INPUT}/*Pair_2*.fastq.gz
cd $Out