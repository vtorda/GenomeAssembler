#!/bin/sh
Out=$PATH_Output/$FILE_base
mkdir $Out
#mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_hard
#mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_Adapters
#mkdir -p $Out/KmerGenie_${FILE_base}/Lighter_${FILE_base}
echo "created a new folder in $(echo ${Out})"
# Trim adapters
bash TrimmomaticAdapter.sh

# hard trimming
bash TrimmomaticHard.sh

# KmerGenie Adapter Trimmed Reads
bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters _AdaptRemovePair

# lighter
bash Lighter3.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters

# Fastqc
bash FastQC5.sh $PATH_Input

bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters

bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard

bash FastQC5.sh $Out/Lighter_${FILE_base}

# KmerGenie Hard Trimmed Reads
bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard _Trimmed

# KmerGenie Lighter Reads
bash KmerGenie2.sh $Out/Lighter_${FILE_base} _

#ABySS
bash ABySS_PeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
bash ABySS_PeOnly.sh $Out/Lighter_${FILE_base}

