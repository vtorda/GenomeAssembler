#!/bin/bash
source ~/.bashrc
Out=$PATH_Output/$FILE_base
mkdir $Out
mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_hard
mkdir -p $Out/KmerGenie_${FILE_base}/Trimmomatic_Adapters
mkdir -p $Out/KmerGenie_${FILE_base}/Lighter_${FILE_base}
echo "created a new folder in $(echo ${Out})"
if [ $Meta != 1 ]
then
	echo "Metagenomic assemblers are turned off"
fi
#################
# Trim adapters
#################
mkdir -p $Out/Trimmomatic_${FILE_base}
{ time bash TrimmomaticAdapter.sh > $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.log 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.elog ; } 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.time.txt
echo -e "\nAdapter trimming is finished, time:\n" `cat $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.time.txt`

#################
# hard trimming
#################
{ time bash TrimmomaticHard.sh > $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.log 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.elog ; } 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.time.txt
echo -e "\nHard trimming is finished, time:\n" `cat $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.time.txt`

###################################
# KmerGenie Adapter Trimmed Reads
###################################
{ time bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters _AdaptRemovePair > $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.log 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.elog ; } 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.time.txt
echo -e "\nKmerGenie is finished, time:\n" `cat $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.time.txt`

###########
# lighter
###########
mkdir -p $Out/Lighter_${FILE_base}
{ time bash Lighter3.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters > $Out/Lighter_${FILE_base}/Lighter.log 2> $Out/Lighter_${FILE_base}/Lighter.elog ; } 2> $Out/Lighter_${FILE_base}/Lighter.time.txt
echo -e "\nLighter is finished, time:\n" `cat $Out/Lighter_${FILE_base}/Lighter.time.txt`

##########
# Fastqc
##########
mkdir -p $Out/FastQC_${FILE_base}
{ time bash FastQC5.sh $PATH_Input > $Out/FastQC_${FILE_base}/FastQC_input.log 2> $Out/FastQC_${FILE_base}/FastQC_input.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_input.time.txt
echo -e "\nFastQC-INPUT is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_input.time.txt`

{ time bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters > $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.log 2> $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.time.txt
echo -e "\nFastQC-TrimAdapt is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.time.txt`

{ time bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/FastQC_${FILE_base}/FastQC_TrimHard.log 2> $Out/FastQC_${FILE_base}/FastQC_TrimHard.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_TrimHard.time.txt
echo -e "\nFastQC-TrimHard is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_TrimHard.time.txt`

{ time bash FastQC5.sh $Out/Lighter_${FILE_base} > $Out/FastQC_${FILE_base}/FastQC_Lighter.log 2> $Out/FastQC_${FILE_base}/FastQC_Lighter.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_Lighter.time.txt
echo -e "\nFastQC-Lighter is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_Lighter.time.txt`

################################
# KmerGenie Hard Trimmed Reads
################################
{ time bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard _Trimmed > $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.log 2> $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.elog ; } 2> $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.time.txt
echo -e "\nKmerGenie is finished, time:\n" `cat $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.time.txt`

###########################
# KmerGenie Lighter Reads
###########################
{ time bash KmerGenie2.sh $Out/Lighter_${FILE_base} _ > $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.log 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.elog ; } 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.time.txt
echo -e "\nKmerGenie is finished, time:\n" `cat $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.time.txt`

########
#ABySS
########
conda activate kat_abyss_spades
Out=$PATH_Output/$FILE_base
mkdir -p $Out/ABySS_${FILE_base}
{ time bash ABySS_PeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/ABySS_${FILE_base}/ABySS_Trim.log 2> $Out/ABySS_${FILE_base}/ABySS_Trim.elog ; } 2> $Out/ABySS_${FILE_base}/ABySS_Trim.time.txt
echo -e "\nABySS-Trimmomatic is finished, time:\n" `cat $Out/ABySS_${FILE_base}/ABySS_Trim.time.txt`

{ time bash ABySS_PeOnly.sh $Out/Lighter_${FILE_base} > $Out/ABySS_${FILE_base}/ABySS_Lighter.log 2> $Out/ABySS_${FILE_base}/ABySS_Lighter.elog ; } 2> $Out/ABySS_${FILE_base}/ABySS_Lighter.time.txt
echo -e "\nABySS-lighter is finished, time:\n" `cat $Out/ABySS_${FILE_base}/ABySS_Lighter.time.txt`

#########
#SPAdes
#########
mkdir -p $Out/SPAdes_${FILE_base}
{ time bash Spades.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta > $Out/SPAdes_${FILE_base}/SPAdes_Trim.log 2> $Out/SPAdes_${FILE_base}/SPAdes_Trim.elog ; } 2> $Out/SPAdes_${FILE_base}/SPAdes_Trim.time.txt
echo -e "\nSPAdes-Trim is finished, time:\n" `cat $Out/SPAdes_${FILE_base}/SPAdes_Trim.time.txt`

{ time bash Spades_PeOnly.sh $Out/Lighter_${FILE_base} $Multicell $Meta > $Out/SPAdes_${FILE_base}/SPAdes_lighter.log 2> $Out/SPAdes_${FILE_base}/SPAdes_lighter.elog ; } 2> $Out/SPAdes_${FILE_base}/SPAdes_lighter.time.txt
echo -e "\nSPAdes-Lighter is finished, time:\n" `cat $Out/SPAdes_${FILE_base}/SPAdes_lighter.time.txt`
##########
#Masurca
##########
mkdir -p $Out/Masurca_${FILE_base}
{ time bash Masurca.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/Masurca_${FILE_base}/Masurca_Trim.log 2> $Out/Masurca_${FILE_base}/Masurca_Trim.elog ; } 2> $Out/Masurca_${FILE_base}/Masurca_Trim.time.txt
echo -e "\nMasurca-Trim is finished, time:\n" `cat $Out/Masurca_${FILE_base}/Masurca_Trim.time.txt`

{ time bash Masurca.sh $Out/Lighter_${FILE_base} > $Out/Masurca_${FILE_base}/Masurca_lighter.log 2> $Out/Masurca_${FILE_base}/Masurca_lighter.elog ; } 2> $Out/Masurca_${FILE_base}/Masurca_lighter.time.txt
echo -e "\nMasurca-Lighter is finished, time:\n" `cat $Out/Masurca_${FILE_base}/SPAdes_lighter.time.txt`

conda deactivate

##########
#Megahit
##########
mkdir -p $Out/Megahit_${FILE_base}
{ time bash MegahitPeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta > $Out/Megahit_${FILE_base}/Megahit_Trim.log 2> $Out/Megahit_${FILE_base}/Megahit_Trim.elog ; } 2> $Out/Megahit_${FILE_base}/Megahit_Trim.time.txt
echo -e "\nMegahit-Trim is finished, time:\n" `cat $Out/Megahit_${FILE_base}/Megahit_Trim.time.txt`

{ time bash MegahitPeOnly.sh $Out/Lighter_${FILE_base} $Multicell $Meta > $Out/Megahit_${FILE_base}/Megahit_Lighter.log 2> $Out/Megahit_${FILE_base}/Megahit_Lighter.elog ; } 2> $Out/Megahit_${FILE_base}/Megahit_Lighter.time.txt
echo -e "\nMegahit-Trim is finished, time:\n" `cat $Out/Megahit_${FILE_base}/Megahit_Lighter.time.txt`

#######
#IDBA
#######
mkdir -p $Out/IDBA_${FILE_base}
{ time bash IDBA_Trimmomatic.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/IDBA_${FILE_base}/IDBA_Trim.log 2> $Out/IDBA_${FILE_base}/IDBA_Trim.elog ; } 2> $Out/IDBA_${FILE_base}/IDBA_Trim.time.txt
echo -e "\nIDBA-Trim is finished, time:\n" `cat $Out/IDBA_${FILE_base}/IDBA_Trim.time.txt`

{ time bash IDBA_Lighter.sh $Out/Lighter_${FILE_base} > $Out/IDBA_${FILE_base}/IDBA_Lighter.log 2> $Out/IDBA_${FILE_base}/IDBA_Lighter.elog ; } 2> $Out/IDBA_${FILE_base}/IDBA_Lighter.time.txt
echo -e "\nIDBA-Lighter is finished, time:\n" `cat $Out/IDBA_${FILE_base}/IDBA_Lighter.time.txt`

####################################
# gather all scaffolds in one file
cat ${Out}/ABySS_RHW620_downsB/Lighter_RHW620_downsB/*scaffolds_to_anal.txt ${Out}/ABySS_RHW620_downsB/Trimmomatic_hard/*scaffolds_to_anal.txt \
${Out}/SPAdes_RHW620_downsB/*scaffolds_to_anal.txt $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt \
${Out}/IDBA_${FILE_base}/IDBA_scaffolds_to_anal.txt $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt > ${Out}/All_raw_scaffolds.fasta

#############
# polishing
#############
conda activate busco_env
Out=$PATH_Output/$FILE_base
mkdir -p $Out/Polished_genomes
{ time bash Polishing.sh > $Out/IDBA_${FILE_base}/Polishing.log 2> $Out/Polished_genomes/Polishing.elog ; } 2> $Out/Polished_genomes/Polishing.time.txt
echo -e "\nPolishing is finished, time:\n" `cat $Out/Polished_genomes/Polishing.time.txt`
conda deactivate

#########
# BUSCO
#########
conda activate busco_env
Out=$PATH_Output/$FILE_base
mkdir -p $Out/BUSCO
{ time bash BUSCO.sh $Out/Polished_genomes polished_filtered.fasta > $Out/BUSCO/BUSCO.log 2> $Out/BUSCO/BUSCO.elog ; } 2> $Out/BUSCO/BUSCO.time.txt
echo -e "\nBUSCO is finished, time:\n" `cat $Out/BUSCO/BUSCO.time.txt`
conda deactivate

########
#Quast
########
mkdir -p $Out/Quast
{ time bash Quast.sh $Out/Polished_genomes polished_filtered.fasta > $Out/Quast/Quast.log 2> $Out/Quast/Quast.elog ; } 2> $Out/Quast/Quast.time.txt
echo -e "\nQuast is finished, time:\n" `cat $Out/Quast/Quast.time.txt`
#if [ $Meta ]
#then
{ time bash MetaQuast.sh $Out/Polished_genomes polished_filtered.fasta > $Out/Quast/Quast_meta.log 2> $Out/Quast/Quast_meta.elog ; } 2> $Out/Quast/Quast_meta.time.txt
echo -e "\nQuast-Meta is finished, time:\n" `cat $Out/Quast/Quast_meta.time.txt`
#fi

#######
# KAT
#######

#KAT kat crashes randomly but I tried to come up with a solution
conda activate kat_abyss_spades
Out=$PATH_Output/$FILE_base
mkdir -p $Out/KAT_${FILE_base}
{ time bash KAT3.sh > $Out/KAT_${FILE_base}/KAT_read.log 2> $Out/KAT_${FILE_base}/KAT_read.elog ; } 2> $Out/KAT_${FILE_base}/KAT_read.time.txt # read stat
echo -e "\nKAT-read is finished, time:\n" `cat $Out/KAT_${FILE_base}/KAT_read.time.txt`

{ time bash KAT_assembly4.sh > $Out/KAT_${FILE_base}/KAT_assembly.log 2> $Out/KAT_${FILE_base}/KAT_assembly.elog ; } 2> $Out/KAT_${FILE_base}/KAT_assembly.time.txt
echo -e "\nKAT-read is finished, time:\n" `cat $Out/KAT_${FILE_base}/KAT_assembly.time.txt`

conda deactivate

# multiQC
if [ $ignore_quast = Trimmomatic ]
then
	ignore=$Out'/Quast/*/Trimmomatic/*'
	mkdir -p $Out/Quast_ignore
	mkdir -p $Out/Quast_ignore/polished_filtered
	mkdir -p $Out/Quast_ignore/polished_filtered_meta
	mv $Out/Quast/polished_filtered/Trimmomatic $Out/Quast_ignore/polished_filtered/
	mv $Out/Quast/\polished_filtered_meta/Trimmomatic $Out/Quast_ignore/polished_filtered/
fi
if [ $ignore_quast = Lighter ]
then
	ignore=$Out'/*/Lighter/*'
	mkdir -p $Out/Quast_ignore
	mkdir -p $Out/Quast_ignore/polished_filtered
	mkdir -p $Out/Quast_ignore/polished_filtered_meta
	mv $Out/Quast/polished_filtered/Lighter $Out/Quast_ignore/polished_filtered/
	mv $Out/Quast/\polished_filtered_meta/Lighter $Out/Quast_ignore/polished_filtered/
fi
echo "$ignore"
echo $Out/Polished_genomes/Polishing_files
echo multiqc -o $Out/MultiQC --ignore "$ignore" --ignore "$Out/Polished_genomes/Polishing_files" -p -d -dd 1 $Out/FastQC_$FILE_base $Out/BUSCO $Out/Polished_genomes $Out/Quast $Out/Trimmomatic_$FILE_base $Out/KAT_${FILE_base}
time multiqc -o $Out/MultiQC --ignore \\""$ignore"\\" --ignore "$Out/Polished_genomes/Polishing_files" -p -d -dd 1 $Out/FastQC_$FILE_base $Out/BUSCO $Out/Polished_genomes $Out/Quast $Out/Trimmomatic_$FILE_base $Out/KAT_${FILE_base}
