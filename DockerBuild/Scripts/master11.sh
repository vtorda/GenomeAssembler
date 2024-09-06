#!/bin/bash
source ~/.bashrc
Out=$PATH_Output/$FILE_base
#mkdir $Out
#mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_hard
#mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_Adapters
#mkdir -p $Out/KmerGenie_${FILE_base}/Lighter_${FILE_base}
echo "created a new folder in $(echo ${Out})"
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
#conda activate kat_abyss_spades
#Out=$PATH_Output/$FILE_base
#bash ABySS_PeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
#bash ABySS_PeOnly.sh $Out/Lighter_${FILE_base}

#SPAdes
#bash Spades.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta
#bash Spades_PeOnly.sh $Out/Lighter_${FILE_base} $Multicell $Meta

#Masurca

#bash Masurca.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
#bash Masurca.sh $Out/Lighter_${FILE_base}

#conda deactivate

#Megahit

#bash MegahitPeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta
#bash MegahitPeOnly.sh $Out/Lighter_${FILE_base} $Multicell $Meta

#IDBA
#bash IDBA_Trimmomatic.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard
#bash IDBA_Lighter.sh $Out/Lighter_${FILE_base}

# gather all scaffolds in one file
#cat ${Out}/ABySS_RHW620_downsB/Lighter_RHW620_downsB/*scaffolds_to_anal.txt ${Out}/ABySS_RHW620_downsB/Trimmomatic_hard/*scaffolds_to_anal.txt \
#${Out}/SPAdes_RHW620_downsB/*scaffolds_to_anal.txt $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt \
#${Out}/IDBA_${FILE_base}/IDBA_scaffolds_to_anal.txt $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt > ${Out}/All_raw_scaffolds.fasta

# polishing
#conda activate busco_env
#Out=$PATH_Output/$FILE_base
#bash Polishing.sh
#conda deactivate


# BUSCO
#conda activate busco_env
#Out=$PATH_Output/$FILE_base
#bash BUSCO.sh $Out/Polished_genomes polished_filtered
#conda deactivate

#bash Quast.sh $Out/Polished_genomes polished_filtered.fasta
#if [ $Meta ]
#then
#	bash MetaQuast.sh $Out/Polished_genomes polished_filtered.fasta
#fi

#KAT kat crashes randomly
#conda activate kat_abyss_spades
#Out=$PATH_Output/$FILE_base
#bash KAT3.sh # read stat
#bash KAT_assembly3.sh ${Out}/ABySS_${FILE_base}/Trimmomatic_hard ${Out}/Trimmomatic_${FILE_base}/Trimmomatic_hard # assembly stat
#bash KAT_assembly3.sh ${Out}/ABySS_${FILE_base}/Lighter_RHW620_downsB ${Out}/Lighter_${FILE_base} # assembly stat
#conda deactivate

# multiQC
if [ $ignore_quast = Trimmomatic ]
then
ignore=$Out'/Quast/*/Trimmomatic/*'
fi
if [ $ignore_quast = Lighter ]
then
ignore=$Out'/*/Trimmomatic/*'
fi
echo "$ignore"
echo $Out/Polished_genomes/Polishing_files
echo multiqc -o $Out/MultiQC -x "$ignore" -x "$Out/Polished_genomes/Polishing_files" -p -d -dd 1 $Out/FastQC_$FILE_base $Out/BUSCO $Out/Polished_genomes $Out/Quast $Out/Trimmomatic_$FILE_base
multiqc -o $Out/MultiQC -x "$ignore" -x "$Out/Polished_genomes/Polishing_files" -p -d -dd 1 $Out/FastQC_$FILE_base $Out/BUSCO $Out/Polished_genomes $Out/Quast $Out/Trimmomatic_$FILE_base
