#!/bin/bash
source ~/.bashrc
Out=$PATH_Output/$FILE_base
#mkdir $Out
#mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_hard
#mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_Adapters
#mkdir -p $Out/KmerGenie_${FILE_base}/Lighter_${FILE_base}
#echo "created a new folder in $(echo ${Out})"
# Trim adapters
#bash TrimmomaticAdapter.sh

# hard trimming
#bash TrimmomaticHard.sh

# KmerGenie Adapter Trimmed Reads
#bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters _AdaptRemovePair

# lighter
#bash Lighter3.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters

# Fastqc
#bash FastQC5.sh $PATH_Input

#bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters

#bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard

#bash FastQC5.sh $Out/Lighter_${FILE_base}

# KmerGenie Hard Trimmed Reads
#bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard _Trimmed

# KmerGenie Lighter Reads
#bash KmerGenie2.sh $Out/Lighter_${FILE_base} _

#ABySS
conda activate kat_abyss_spades
Out=$PATH_Output/$FILE_base
#bash ABySS_PeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
#bash ABySS_PeOnly.sh $Out/Lighter_${FILE_base}
#KAT kat crashes randomly
bash KAT3.sh # read stat
bash KAT_assembly3.sh ${Out}/ABySS_${FILE_base}/Trimmomatic_hard ${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard # read stat
bash KAT_assembly3.sh ${Out}/ABySS_${FILE_base}/Lighter_RHW620_downsB ${Out}/Lighter_${FILE_base} # read stat
#bash KAT_assembly.sh ${Out}/ABySS_${FILE_base}/Trimmomatic_hard ${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard
#bash KAT_assembly.sh ${Out}/ABySS_${FILE_base}/Lighter_RHW620_downsB ${Out}/Lighter_${FILE_base}
conda deactivate
