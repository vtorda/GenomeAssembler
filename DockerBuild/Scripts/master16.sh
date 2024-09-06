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
if [ $ReadProc != 1 ]
then
	echo "Assuming that all read processess have been finished: Trimmomatic, Lighter, FastQC and KmerGenie are turned off "
fi
if [ $ABySS != 1 ]
then
	echo "ABySS is turned off "
fi
if [ $SPAdes != 1 ]
then
	echo "SPAdes is turned off "
fi
if [ $masurca != 1 ]
then
	echo "Masurca is turned off "
fi
if [ $megahit != 1 ]
then
	echo "Megahit is turned off "
fi
if [ $IDBA != 1 ]
then
	echo "IDBA is turned off "
fi
if [ $Polish != 1 ]
then
	echo "Polishing is turned off "
fi
if [ $quast != 1 ]
then
	echo "Quast is turned off "
fi
if [ $KAT != 1 ]
then
	echo "KAT is turned off "
fi
if [ $multiqc != 1 ]
then
	echo "multiqc is turned off "
fi
if [ $ReadProc = 1 ]
then
	#################
	# Trim adapters
	#################
	echo "Adapter trimming is started, time: $(date +"%T")"
	mkdir -p $Out/Trimmomatic_${FILE_base}
	{ time bash TrimmomaticAdapter.sh > $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.log 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.elog ; } 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.time.txt
	echo -e "\nAdapter trimming is finished, time:\n" `cat $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.time.txt`

	#################
	# hard trimming
	#################
	echo "Hard trimming is started, time: $(date +"%T")"
	{ time bash TrimmomaticHard.sh > $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.log 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.elog ; } 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.time.txt
	echo -e "\nHard trimming is finished, time:\n" `cat $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.time.txt`

	###################################
	# KmerGenie Adapter Trimmed Reads
	###################################
	echo "KmerGenie on Adapte-trimmed reads is started, time: $(date +"%T")"
	{ time bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters _AdaptRemovePair > $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.log 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.elog ; } 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.time.txt
	echo -e "\nKmerGenie is finished, time:\n" `cat $Out/KmerGenie_${FILE_base}/KmerGenie_Adapter.time.txt`

	###########
	# lighter
	###########
	echo "Lighter is started, time: $(date +"%T")"
	mkdir -p $Out/Lighter_${FILE_base}
	{ time bash Lighter3.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters > $Out/Lighter_${FILE_base}/Lighter.log 2> $Out/Lighter_${FILE_base}/Lighter.elog ; } 2> $Out/Lighter_${FILE_base}/Lighter.time.txt
	echo -e "\nLighter is finished, time:\n" `cat $Out/Lighter_${FILE_base}/Lighter.time.txt`

	##########
	# Fastqc and read stat
	##########
	echo "FastQC on raw reads is started, time: $(date +"%T")"
	mkdir -p $Out/FastQC_${FILE_base}
	{ time bash FastQC5.sh $PATH_Input > $Out/FastQC_${FILE_base}/FastQC_input.log 2> $Out/FastQC_${FILE_base}/FastQC_input.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_input.time.txt
	echo -e "\nFastQC-INPUT is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_input.time.txt`

	Read_stat.sh $PATH_Input

	echo "FastQC on adapter-trimmed reads is started, time: $(date +"%T")"
	{ time bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters > $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.log 2> $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.time.txt
	echo -e "\nFastQC-TrimAdapt is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_TrimAdapt.time.txt`

	Read_stat.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters

	echo "FastQC on hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash FastQC5.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/FastQC_${FILE_base}/FastQC_TrimHard.log 2> $Out/FastQC_${FILE_base}/FastQC_TrimHard.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_TrimHard.time.txt
	echo -e "\nFastQC-TrimHard is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_TrimHard.time.txt`

	Read_stat.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard

	echo "FastQC on lighter reads is started, time: $(date +"%T")"
	{ time bash FastQC5.sh $Out/Lighter_${FILE_base} > $Out/FastQC_${FILE_base}/FastQC_Lighter.log 2> $Out/FastQC_${FILE_base}/FastQC_Lighter.elog ; } 2> $Out/FastQC_${FILE_base}/FastQC_Lighter.time.txt
	echo -e "\nFastQC-Lighter is finished, time:\n" `cat $Out/FastQC_${FILE_base}/FastQC_Lighter.time.txt`

	Read_stat.sh $Out/Lighter_${FILE_base}

	################################
	# KmerGenie Hard Trimmed Reads
	################################
	echo "KmerGenie on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash KmerGenie2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard _Trimmed > $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.log 2> $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.elog ; } 2> $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.time.txt
	echo -e "\nKmerGenie is finished, time:\n" `cat $Out/KmerGenie_${FILE_base}/KmerGenie_HardTrim.time.txt`

	###########################
	# KmerGenie Lighter Reads
	###########################
	echo "KmerGenie on Lighter reads is started, time: $(date +"%T")"
	{ time bash KmerGenie2.sh $Out/Lighter_${FILE_base} _ > $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.log 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.elog ; } 2> $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.time.txt
	echo -e "\nKmerGenie is finished, time:\n" `cat $Out/KmerGenie_${FILE_base}/KmerGenie_Lighter.time.txt`

fi
########
#ABySS
########
if [ $ABySS = 1 ]
then
	#conda activate kat_abyss_spades
	source activate kat_abyss_spades
	Out=$PATH_Output/$FILE_base
	mkdir -p $Out/ABySS_${FILE_base}
	echo "ABySS on Hard-trimmed reads is started, time: $(date +"%T")"
	{ /usr/bin/time -v bash ABySS_PeSe.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/ABySS_${FILE_base}/ABySS_Trim.log 2> $Out/ABySS_${FILE_base}/ABySS_Trim.elog ; } 2> $Out/ABySS_${FILE_base}/ABySS_Trim.time.txt
	echo -e "\nABySS-Trimmomatic is finished, time:\n" `cat $Out/ABySS_${FILE_base}/ABySS_Trim.time.txt`

	echo "ABySS on Lighter reads is started, time: $(date +"%T")"
	{ /usr/bin/time -v bash ABySS_PeOnly.sh $Out/Lighter_${FILE_base} > $Out/ABySS_${FILE_base}/ABySS_Lighter.log 2> $Out/ABySS_${FILE_base}/ABySS_Lighter.elog ; } 2> $Out/ABySS_${FILE_base}/ABySS_Lighter.time.txt
	echo -e "\nABySS-lighter is finished, time:\n" `cat $Out/ABySS_${FILE_base}/ABySS_Lighter.time.txt`
	conda deactivate
fi

#########
#SPAdes
#########
if [ $SPAdes = 1 ]
then
	source activate kat_abyss_spades
	mkdir -p $Out/SPAdes_${FILE_base}

	echo "SPAdes on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash Spades.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta > $Out/SPAdes_${FILE_base}/SPAdes_Trim.log 2> $Out/SPAdes_${FILE_base}/SPAdes_Trim.elog ; } 2> $Out/SPAdes_${FILE_base}/SPAdes_Trim.time.txt
	echo -e "\nSPAdes-Trim is finished, time:\n" `cat $Out/SPAdes_${FILE_base}/SPAdes_Trim.time.txt`

	echo "SPAdes on Lighter reads is started, time: $(date +"%T")"
	{ time bash Spades_PeOnly.sh $Out/Lighter_${FILE_base} $Multicell $Meta > $Out/SPAdes_${FILE_base}/SPAdes_lighter.log 2> $Out/SPAdes_${FILE_base}/SPAdes_lighter.elog ; } 2> $Out/SPAdes_${FILE_base}/SPAdes_lighter.time.txt
	echo -e "\nSPAdes-Lighter is finished, time:\n" `cat $Out/SPAdes_${FILE_base}/SPAdes_lighter.time.txt`
	conda deactivate
fi

##########
#Masurca
##########
if [ $masurca = 1 ]
then
	source activate kat_abyss_spades
	mkdir -p $Out/Masurca_${FILE_base}
	echo "Masurca on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash Masurca.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/Masurca_${FILE_base}/Masurca_Trim.log 2> $Out/Masurca_${FILE_base}/Masurca_Trim.elog ; } 2> $Out/Masurca_${FILE_base}/Masurca_Trim.time.txt
	echo -e "\nMasurca-Trim is finished, time:\n" `cat $Out/Masurca_${FILE_base}/Masurca_Trim.time.txt`

	echo "Masurca on Lighter reads is started, time: $(date +"%T")"
	{ time bash Masurca.sh $Out/Lighter_${FILE_base} > $Out/Masurca_${FILE_base}/Masurca_lighter.log 2> $Out/Masurca_${FILE_base}/Masurca_lighter.elog ; } 2> $Out/Masurca_${FILE_base}/Masurca_lighter.time.txt
	echo -e "\nMasurca-Lighter is finished, time:\n" `cat $Out/Masurca_${FILE_base}/SPAdes_lighter.time.txt`
	conda deactivate
fi

##########
#Megahit
##########
if [ $megahit = 1 ]
then
	mkdir -p $Out/Megahit_${FILE_base}
	echo "Megahit on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash MegahitPeSe2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta > $Out/Megahit_${FILE_base}/Megahit_Trim.log 2> $Out/Megahit_${FILE_base}/Megahit_Trim.elog ; } 2> $Out/Megahit_${FILE_base}/Megahit_Trim.time.txt
	echo -e "\nMegahit-Trim is finished, time:\n" `cat $Out/Megahit_${FILE_base}/Megahit_Trim.time.txt`

	echo "Megahit on Lighter reads is started, time: $(date +"%T")"
	{ time bash MegahitPeOnly2.sh $Out/Lighter_${FILE_base} $Multicell $Meta > $Out/Megahit_${FILE_base}/Megahit_Lighter.log 2> $Out/Megahit_${FILE_base}/Megahit_Lighter.elog ; } 2> $Out/Megahit_${FILE_base}/Megahit_Lighter.time.txt
	echo -e "\nMegahit-Trim is finished, time:\n" `cat $Out/Megahit_${FILE_base}/Megahit_Lighter.time.txt`
fi

#######
#IDBA
#######
if [ $IDBA = 1 ]
then
	mkdir -p $Out/IDBA_${FILE_base}
	echo "IDBA on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash IDBA_Trimmomatic.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/IDBA_${FILE_base}/IDBA_Trim.log 2> $Out/IDBA_${FILE_base}/IDBA_Trim.elog ; } 2> $Out/IDBA_${FILE_base}/IDBA_Trim.time.txt
	echo -e "\nIDBA-Trim is finished, time:\n" `cat $Out/IDBA_${FILE_base}/IDBA_Trim.time.txt`

	echo "IDBA on Lighter reads is started, time: $(date +"%T")"
	{ time bash IDBA_Lighter.sh $Out/Lighter_${FILE_base} > $Out/IDBA_${FILE_base}/IDBA_Lighter.log 2> $Out/IDBA_${FILE_base}/IDBA_Lighter.elog ; } 2> $Out/IDBA_${FILE_base}/IDBA_Lighter.time.txt
	echo -e "\nIDBA-Lighter is finished, time:\n" `cat $Out/IDBA_${FILE_base}/IDBA_Lighter.time.txt`
fi

####################################
# gather all scaffolds in one file
cat ${Out}/ABySS_${FILE_base}/Lighter_${FILE_base}/*scaffolds_to_anal.txt ${Out}/ABySS_${FILE_base}/Trimmomatic_hard/*scaffolds_to_anal.txt \
${Out}/SPAdes_${FILE_base}/*scaffolds_to_anal.txt $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt \
${Out}/IDBA_${FILE_base}/IDBA_scaffolds_to_anal.txt $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt > ${Out}/All_raw_scaffolds.fasta

#############
# polishing
#############
if [ $Polish = 1 ]
then
	source activate busco_env
	Out=$PATH_Output/$FILE_base
	mkdir -p $Out/Polished_genomes
	echo "Polishing is started, time: $(date +"%T")"
	{ time bash Polishing2.sh > $Out/Polished_genomes/Polishing.log 2> $Out/Polished_genomes/Polishing.elog ; } 2> $Out/Polished_genomes/Polishing.time.txt
	echo -e "\nPolishing is finished, time:\n" `cat $Out/Polished_genomes/Polishing.time.txt`
	conda deactivate
fi

#########
# BUSCO
#########
#conda activate busco_env
if [ $BUSCO = 1 ]
then
	source activate busco_env
	Out=$PATH_Output/$FILE_base
	mkdir -p $Out/BUSCO
	echo "BUSCO is started, time: $(date +"%T")"
	{ time bash BUSCO.sh $Out/Polished_genomes/Polished_genomes_final polished_filtered.fasta > $Out/BUSCO/BUSCO.log 2> $Out/BUSCO/BUSCO.elog ; } 2> $Out/BUSCO/BUSCO.time.txt
	echo -e "\nBUSCO is finished, time:\n" `cat $Out/BUSCO/BUSCO.time.txt`
	conda deactivate
fi

########
#Quast
########
if [ $quast = 1 ]
then
	mkdir -p $Out/Quast
	echo "Quast is started, time: $(date +"%T")"
	{ time bash Quast.sh $Out/Polished_genomes/Polished_genomes_final polished_filtered.fasta > $Out/Quast/Quast.log 2> $Out/Quast/Quast.elog ; } 2> $Out/Quast/Quast.time.txt
	echo -e "\nQuast is finished, time:\n" `cat $Out/Quast/Quast.time.txt`

	echo "MetaQuast is started, time: $(date +"%T")"
	{ time bash MetaQuast.sh $Out/Polished_genomes/Polished_genomes_final polished_filtered.fasta > $Out/Quast/Quast_meta.log 2> $Out/Quast/Quast_meta.elog ; } 2> $Out/Quast/Quast_meta.time.txt
	echo -e "\nQuast-Meta is finished, time:\n" `cat $Out/Quast/Quast_meta.time.txt`
fi

#######
# KAT
#######
if [ $KAT = 1 ]
then
	#KAT kat crashes randomly but I tried to come up with a solution
	source activate kat_abyss_spades
	Out=$PATH_Output/$FILE_base
	mkdir -p $Out/KAT_${FILE_base}
	echo "KAT on reads is started, time: $(date +"%T")"
	{ time bash KAT3.sh > $Out/KAT_${FILE_base}/KAT_read.log 2> $Out/KAT_${FILE_base}/KAT_read.elog ; } 2> $Out/KAT_${FILE_base}/KAT_read.time.txt # read stat
	echo -e "\nKAT-read is finished, time:\n" `cat $Out/KAT_${FILE_base}/KAT_read.time.txt`

	echo "KAT on assemblies is started, time: $(date +"%T")"
	{ time bash KAT_assembly4.sh > $Out/KAT_${FILE_base}/KAT_assembly.log 2> $Out/KAT_${FILE_base}/KAT_assembly.elog ; } 2> $Out/KAT_${FILE_base}/KAT_assembly.time.txt
	echo -e "\nKAT-read is finished, time:\n" `cat $Out/KAT_${FILE_base}/KAT_assembly.time.txt`
	conda deactivate
fi

############
# multiQC
############
if [ $multiqc = 1 ]
then
	if [ $ignore_quast = Trimmomatic ]
	then
		ignore=$Out'/Quast/*/Trimmomatic/*'
		mkdir -p $Out/Quast_ignore
		mkdir -p $Out/Quast_ignore/polished_filtered
		mkdir -p $Out/Quast_ignore/polished_filtered_meta
		mv $Out/Quast/polished_filtered/Trimmomatic $Out/Quast_ignore/polished_filtered/
		mv $Out/Quast/polished_filtered_meta/Trimmomatic $Out/Quast_ignore/polished_filtered_meta/
	fi
	if [ $ignore_quast = Lighter ]
	then
		ignore=$Out'/*/Lighter/*'
		mkdir -p $Out/Quast_ignore
		mkdir -p $Out/Quast_ignore/polished_filtered
		mkdir -p $Out/Quast_ignore/polished_filtered_meta
		mv $Out/Quast/polished_filtered/Lighter $Out/Quast_ignore/polished_filtered/
		mv $Out/Quast/polished_filtered_meta/Lighter $Out/Quast_ignore/polished_filtered_meta/
	fi
	#echo "$ignore"
	#echo $Out/Polished_genomes/Polishing_files
	#echo multiqc -o $Out/MultiQC --ignore "$ignore" --ignore "$Out/Polished_genomes/Polishing_files" -p -d -dd 1 $Out/FastQC_$FILE_base $Out/BUSCO $Out/Polished_genomes $Out/Quast $Out/Trimmomatic_$FILE_base $Out/KAT_${FILE_base}
	echo "MultiQC is started, time: $(date +"%T")"
	time multiqc -o $Out/MultiQC --ignore \\""$ignore"\\" --ignore "$Out/Polished_genomes/Polishing_files" -p -d -dd 1 $Out/FastQC_$FILE_base $Out/BUSCO $Out/Polished_genomes $Out/Quast $Out/Trimmomatic_$FILE_base $Out/KAT_${FILE_base}
fi