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
if [ $POLCA = 1 ]
then
	echo "Polishing will be performed by POLCA"
fi
if [ $Pilon = 1 ]
then
	echo "Polishing will be performed by Pilon"
fi
if [ $NextPol = 1 ]
then
	echo "Polishing will be performed by NextPolish"
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
source activate base
	#################
	# Trim adapters
	#################
	echo "Adapter trimming is started, time: $(date +"%T")"
	mkdir -p $Out/Trimmomatic_${FILE_base}
	{ time bash TrimmomaticAdapter2.sh > $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.log 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.elog ; } 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.time.txt
	echo -e "\nAdapter trimming is finished, time:\n" `cat $Out/Trimmomatic_${FILE_base}/TrimmomaticAdapter.time.txt`

	#################
	# stringent trimming
	#################
	echo "Hard trimming is started, time: $(date +"%T")"
	{ time bash TrimmomaticHard2.sh > $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.log 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.elog ; } 2> $Out/Trimmomatic_${FILE_base}/TrimmomaticHard.time.txt
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

	#Read_stat.sh $PATH_Input # change this function to read only fastq with the base names...

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

conda deactivate
fi


mkdir -p $Out/Raw_genomes
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
	cp $(cat ${Out}/ABySS_${FILE_base}/Lighter_${FILE_base}/*scaffolds_to_anal.txt) $Out/Raw_genomes 
	cp $(cat ${Out}/ABySS_${FILE_base}/Trimmomatic_hard/*scaffolds_to_anal.txt) $Out/Raw_genomes 
	conda deactivate
fi


if [ $LowStorage = 1 ]
then
	cd ${Out}/ABySS_${FILE_base}/Lighter_${FILE_base}
	rm -r kmer_*
	cd ${Out}/ABySS_${FILE_base}/Trimmomatic_hard/
	rm -r kmer_*
	cd ${Out}
fi


#########
#SPAdes
#########
if [ $SPAdes = 1 ]
then
	source activate kat_abyss_spades
	mkdir -p $Out/SPAdes_${FILE_base}

	echo "SPAdes on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash Spades2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta > $Out/SPAdes_${FILE_base}/SPAdes_Trim.log 2> $Out/SPAdes_${FILE_base}/SPAdes_Trim.elog ; } 2> $Out/SPAdes_${FILE_base}/SPAdes_Trim.time.txt
	echo -e "\nSPAdes-Trim is finished, time:\n" `cat $Out/SPAdes_${FILE_base}/SPAdes_Trim.time.txt`

	echo "SPAdes on Lighter reads is started, time: $(date +"%T")"
	{ time bash Spades_PeOnly2.sh $Out/Lighter_${FILE_base} $Multicell $Meta > $Out/SPAdes_${FILE_base}/SPAdes_lighter.log 2> $Out/SPAdes_${FILE_base}/SPAdes_lighter.elog ; } 2> $Out/SPAdes_${FILE_base}/SPAdes_lighter.time.txt
	echo -e "\nSPAdes-Lighter is finished, time:\n" `cat $Out/SPAdes_${FILE_base}/SPAdes_lighter.time.txt`
	cp $(cat ${Out}/SPAdes_${FILE_base}/*scaffolds_to_anal.txt) $Out/Raw_genomes 
	conda deactivate
fi




if [ $LowStorage = 1 ]
then
	cd ${Out}/SPAdes_${FILE_base}/Trimmomatic_hard/Multicell
	rm -r K*
	rm -r misc
	rm -r tmp
	cd ${Out}/SPAdes_${FILE_base}/Lighter_${FILE_base}/Multicell
	rm -r K*
	rm -r misc
	rm -r tmp
	cd ${Out}
fi

##########
#Masurca
##########
if [ $masurca = 1 ]
then
	source activate kat_abyss_spades
	mkdir -p $Out/Masurca_${FILE_base}
	echo "Masurca on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash Masurca2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/Masurca_${FILE_base}/Masurca_Trim.log 2> $Out/Masurca_${FILE_base}/Masurca_Trim.elog ; } 2> $Out/Masurca_${FILE_base}/Masurca_Trim.time.txt
	echo -e "\nMasurca-Trim is finished, time:\n" `cat $Out/Masurca_${FILE_base}/Masurca_Trim.time.txt`

	echo "Masurca on Lighter reads is started, time: $(date +"%T")"
	{ time bash Masurca2.sh $Out/Lighter_${FILE_base} > $Out/Masurca_${FILE_base}/Masurca_lighter.log 2> $Out/Masurca_${FILE_base}/Masurca_lighter.elog ; } 2> $Out/Masurca_${FILE_base}/Masurca_lighter.time.txt
	echo -e "\nMasurca-Lighter is finished, time:\n" `cat $Out/Masurca_${FILE_base}/SPAdes_lighter.time.txt`
	conda deactivate
fi


cp $(cat $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt) $Out/Raw_genomes 

if [ $LowStorage = 1 ]
then
	cd $Out/Masurca_${FILE_base}/Lighter_${FILE_base}_kauto/CA
	rm -r *-*
	rm -r genome*
	rm -r ovlStoreBackup
	cd $Out/Masurca_${FILE_base}/Lighter_${FILE_base}_kauto
	rm -r work1
	rm *.fastq quorum_mer_db.jf pe.cor.fa k_u_hash_0 superReadSequences_shr.frg unitig_layout.txt unitig_cov.txt # this can be find in the Masurca2.sh, but if I ran an older version than I need to clean up these files without running the masurca script
	#rm $Out/Masurca_${FILE_base}/Lighter_${FILE_base}_kauto/*.fastq
	
	cd $Out/Masurca_${FILE_base}/Lighter_${FILE_base}_kmergenie/CA
	rm -r *-*
	rm -r genome*
	rm -r ovlStoreBackup
	cd $Out/Masurca_${FILE_base}/Lighter_${FILE_base}_kmergenie
	rm -r work1
	rm *.fastq quorum_mer_db.jf pe.cor.fa k_u_hash_0 superReadSequences_shr.frg unitig_layout.txt unitig_cov.txt # this can be find in the Masurca2.sh, but if I ran an older version than I need to clean up these files without running the masurca script
	#rm $Out/Masurca_${FILE_base}/Lighter_${FILE_base}_kmergenie/*.fastq
	
	cd $Out/Masurca_${FILE_base}/Trimmomatic_hard_kauto/CA
	rm -r *-*
	rm -r genome*
	rm -r ovlStoreBackup
	cd $Out/Masurca_${FILE_base}/Trimmomatic_hard_kauto
	rm -r work1
	#rm $Out/Masurca_${FILE_base}/Trimmomatic_hard_kauto/*.fastq
	rm *.fastq quorum_mer_db.jf pe.cor.fa k_u_hash_0 superReadSequences_shr.frg unitig_layout.txt unitig_cov.txt # this can be find in the Masurca2.sh, but if I ran an older version than I need to clean up these files without running the masurca script
	
	cd $Out/Masurca_${FILE_base}/Trimmomatic_hard_kmergenie/CA
	rm -r *-*
	rm -r genome*
	rm -r ovlStoreBackup
	cd $Out/Masurca_${FILE_base}/Trimmomatic_hard_kmergenie
	rm -r work1
	rm *.fastq quorum_mer_db.jf pe.cor.fa k_u_hash_0 superReadSequences_shr.frg unitig_layout.txt unitig_cov.txt # this can be find in the Masurca2.sh, but if I ran an older version than I need to clean up these files without running the masurca script
	#rm $Out/Masurca_${FILE_base}/Trimmomatic_hard_kmergenie/*.fastq
	cd $Out
fi


##########
#Megahit
##########
if [ $megahit = 1 ]
then
source activate base
	mkdir -p $Out/Megahit_${FILE_base}
	echo "Megahit on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash MegahitPeSe2.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard $Multicell $Meta > $Out/Megahit_${FILE_base}/Megahit_Trim.log 2> $Out/Megahit_${FILE_base}/Megahit_Trim.elog ; } 2> $Out/Megahit_${FILE_base}/Megahit_Trim.time.txt
	echo -e "\nMegahit-Trim is finished, time:\n" `cat $Out/Megahit_${FILE_base}/Megahit_Trim.time.txt`

	echo "Megahit on Lighter reads is started, time: $(date +"%T")"
	{ time bash MegahitPeOnly2.sh $Out/Lighter_${FILE_base} $Multicell $Meta > $Out/Megahit_${FILE_base}/Megahit_Lighter.log 2> $Out/Megahit_${FILE_base}/Megahit_Lighter.elog ; } 2> $Out/Megahit_${FILE_base}/Megahit_Lighter.time.txt
	echo -e "\nMegahit-Trim is finished, time:\n" `cat $Out/Megahit_${FILE_base}/Megahit_Lighter.time.txt`
conda deactivate
fi

cp $(cat $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt) $Out/Raw_genomes 


if [ $LowStorage = 1 ]
then
	cd $Out/Megahit_${FILE_base}/Lighter_${FILE_base}/Multicell
	rm -r intermediate_contigs
	cd $Out/Megahit_${FILE_base}/Trimmomatic_hard/Multicell
	rm -r intermediate_contigs
	cd $Out
fi

#######
#IDBA
#######
if [ $IDBA = 1 ]
then
source activate base
	mkdir -p $Out/IDBA_${FILE_base}
	echo "IDBA on Hard-trimmed reads is started, time: $(date +"%T")"
	{ time bash IDBA_Trimmomatic.sh $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard > $Out/IDBA_${FILE_base}/IDBA_Trim.log 2> $Out/IDBA_${FILE_base}/IDBA_Trim.elog ; } 2> $Out/IDBA_${FILE_base}/IDBA_Trim.time.txt
	echo -e "\nIDBA-Trim is finished, time:\n" `cat $Out/IDBA_${FILE_base}/IDBA_Trim.time.txt`

	echo "IDBA on Lighter reads is started, time: $(date +"%T")"
	{ time bash IDBA_Lighter.sh $Out/Lighter_${FILE_base} > $Out/IDBA_${FILE_base}/IDBA_Lighter.log 2> $Out/IDBA_${FILE_base}/IDBA_Lighter.elog ; } 2> $Out/IDBA_${FILE_base}/IDBA_Lighter.time.txt
	echo -e "\nIDBA-Lighter is finished, time:\n" `cat $Out/IDBA_${FILE_base}/IDBA_Lighter.time.txt`
conda deactivate
fi

cp $(cat ${Out}/IDBA_${FILE_base}/IDBA_scaffolds_to_anal.txt) $Out/Raw_genomes 

if [ $LowStorage = 1 ]
then
	rm $Out/IDBA_${FILE_base}/Trimmomatic_hard/align*
	rm $Out/IDBA_${FILE_base}/Trimmomatic_hard/contig*
	rm $Out/IDBA_${FILE_base}/Trimmomatic_hard/graph*
	rm $Out/IDBA_${FILE_base}/Trimmomatic_hard/kmer
	rm $Out/IDBA_${FILE_base}/Trimmomatic_hard/local*
	rm $Out/IDBA_${FILE_base}/Lighter_${FILE_base}/align*
	rm $Out/IDBA_${FILE_base}/Lighter_${FILE_base}/contig*
	rm $Out/IDBA_${FILE_base}/Lighter_${FILE_base}/graph*
	rm $Out/IDBA_${FILE_base}/Lighter_${FILE_base}/kmer
	rm $Out/IDBA_${FILE_base}/Lighter_${FILE_base}/local*
fi

####################################
# gather all scaffolds in one file if it hasn't done before... 

cat ${Out}/ABySS_${FILE_base}/Lighter_${FILE_base}/*scaffolds_to_anal.txt ${Out}/ABySS_${FILE_base}/Trimmomatic_hard/*scaffolds_to_anal.txt \
${Out}/SPAdes_${FILE_base}/*scaffolds_to_anal.txt $Out/Megahit_${FILE_base}/Megahit_scaffolds_to_anal.txt \
${Out}/IDBA_${FILE_base}/IDBA_scaffolds_to_anal.txt $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt > ${Out}/All_raw_scaffolds.fasta

#############
# polishing
#############
if [ $Polish = 1 ]
then
	if [ $Pilon = 1 ]
	then
		source activate busco
		Out=$PATH_Output/$FILE_base
		mkdir -p $Out/Polished_genomes
		echo "Polishing is started, time: $(date +"%T")"
		{ time bash Polishing2.sh > $Out/Polished_genomes/Polishing.log 2> $Out/Polished_genomes/Polishing.elog ; } 2> $Out/Polished_genomes/Polishing.time.txt
		echo -e "\nPolishing is finished, time:\n" `cat $Out/Polished_genomes/Polishing.time.txt`
		conda deactivate
	fi
	if [ $NextPol = 1 ]
	then
		source activate base
		Out=$PATH_Output/$FILE_base
		mkdir -p $Out/Polished_genomes
		echo "Polishing is started, time: $(date +"%T")"
		{ time bash Polishing_NextPolish.sh > $Out/Polished_genomes/Polishing.log 2> $Out/Polished_genomes/Polishing.elog ; } 2> $Out/Polished_genomes/Polishing.time.txt 
		conda deactivate
	fi
	
	pattern=polished.fasta
	genome_path=$Out/Polished_genomes/Polished_genomes_final
	
fi

if [ $Polish != 1 ]
	then
		#mkdir -p $Out/Raw_genomes
		#cp $(cat ${Out}/All_raw_scaffolds.fasta) $Out/Raw_genomes 
		pattern=scaffolds.fa
		genome_path=$Out/Raw_genomes
fi

if [ $Polish != 1 ]
then
	if [ $samtools = 1 ]
	then
		source activate busco
		SamtoolsStat.sh 
		conda deactivate
	fi
fi

#########
# BUSCO
#########
#conda activate busco_env
if [ $BUSCO = 1 ]
then
	source activate busco
	Out=$PATH_Output/$FILE_base
	mkdir -p $Out/BUSCO
	echo "BUSCO is started, time: $(date +"%T")"
	{ time bash BUSCO.sh $genome_path $pattern > $Out/BUSCO/BUSCO.log 2> $Out/BUSCO/BUSCO.elog ; } 2> $Out/BUSCO/BUSCO.time.txt
	echo -e "\nBUSCO is finished, time:\n" `cat $Out/BUSCO/BUSCO.time.txt`
	conda deactivate
fi


########
#Quast
########
if [ $quast = 1 ]
then
	source activate quast
	mkdir -p $Out/Quast
	echo "Quast is started, time: $(date +"%T")"
	{ time bash Quast.sh $genome_path $pattern > $Out/Quast/Quast.log 2> $Out/Quast/Quast.elog ; } 2> $Out/Quast/Quast.time.txt
	echo -e "\nQuast is finished, time:\n" `cat $Out/Quast/Quast.time.txt`

	#echo "MetaQuast is started, time: $(date +"%T")"
	#{ time bash MetaQuast.sh $Out/Polished_genomes/Polished_genomes_final polished.fasta > $Out/Quast/Quast_meta.log 2> $Out/Quast/Quast_meta.elog ; } 2> $Out/Quast/Quast_meta.time.txt
	#echo -e "\nQuast-Meta is finished, time:\n" `cat $Out/Quast/Quast_meta.time.txt`
	conda deactivate
fi

if [ $Polish != 1 ]
then
	if [ $samtools != 1 ]
	then
		if [ $quast = 1 ] # I could use quast generated files and skip SamtoolsStat.sh though quast results is a bit different from that of the SamtoolsStat.sh
		then
			OutputDir=$Out/RawGenomesSamtoolsStat
			mkdir -p $OutputDir
			cp $Out/Quast/scaffolds/Trimmomatic/reads_stats/*Trimmomatic*.stat OutputDir/
			cp $Out/Quast/scaffolds/Lighter/reads_stats/*Lighter*.stat OutputDir/
		fi
	fi
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
	{ time bash KAT5.sh > $Out/KAT_${FILE_base}/KAT_read.log 2> $Out/KAT_${FILE_base}/KAT_read.elog ; } 2> $Out/KAT_${FILE_base}/KAT_read.time.txt # read stat
	echo -e "\nKAT-read is finished, time:\n" `cat $Out/KAT_${FILE_base}/KAT_read.time.txt`

	echo "KAT on assemblies is started, time: $(date +"%T")"
	{ time bash KAT_assembly6.sh $genome_path > $Out/KAT_${FILE_base}/KAT_assembly.log 2> $Out/KAT_${FILE_base}/KAT_assembly.elog ; } 2> $Out/KAT_${FILE_base}/KAT_assembly.time.txt
	echo -e "\nKAT-read is finished, time:\n" `cat $Out/KAT_${FILE_base}/KAT_assembly.time.txt`
	conda deactivate
fi

############
# multiQC
############
if [ $multiqc = 1 ] # this section can be deleted...
then
	echo "MultiQC is started, time: $(date +"%T")"
	source activate base
	if [ $Polish = 1 ]
	then
		busco_files=$Out/BUSCO/polished/Summary_files
		samtools_files=$Out/Polished_genomes/Polished_genomes_stat
		quast_files=$Out/Quast/polished/Reports/$ReportWhat
	fi
	if [ $Polish != 1 ]
	then
		busco_files=$Out/BUSCO/scaffolds/Summary_files
		samtools_files=$Out/RawGenomesSamtoolsStat/Raw_genomes_stat
		quast_files=$Out/Quast/scaffolds/Reports/$ReportWhat
	fi
	time multiqc -o $Out/MultiQC -p -d -dd 1 $Out/FastQC_$FILE_base $busco_files $samtools_files $quast_files $Out/Trimmomatic_$FILE_base
	conda deactivate
fi
mkdir -p $Out/BestAssembly

############
## clear and tidy up files
############
if [ $tidyup = 1 ]
then
	mkdir -p $Out/Reports
	mkdir -p $Out/Reports/KAT
	mkdir -p $Out/Reports/Quast_lighter
	mkdir -p $Out/Reports/BUSCO
	mkdir -p $Out/Reports/Logs
	mkdir -p $Out/Reports/KmerGenie
	#MultiQC
	cp -r $Out/MultiQC $Out/Reports/MultiQC
	#KAT
	cp $Out/KAT_${FILE_base}/AssemblyStat/*.png $Out/Reports/KAT
	cp $Out/KAT_${FILE_base}/ReadStat/*.png $Out/Reports/KAT
	#QUAST
	cp -r $Out/Quast/scaffolds/Lighter/icarus_viewers $Out/Reports/Quast_lighter/icarus_viewers
	cp -r $Out/Quast/scaffolds/Lighter/basic_stats $Out/Reports/Quast_lighter/basic_stats
	cp $Out/Quast/scaffolds/Lighter/report.html $Out/Reports/Quast_lighter/
	cp $Out/Quast/scaffolds/Lighter/icarus.html $Out/Reports/Quast_lighter/
	cp $Out/Quast/scaffolds/Lighter/report.tsv $Out/Reports/Quast_lighter/
	#BUSCO
	cp $Out/BUSCO/scaffolds/Summary_files/*.txt $Out/Reports/BUSCO/
	cp $Out/IDBA_${FILE_base}/*.log $Out/Reports/Logs/
	cp $Out/Megahit_${FILE_base}/Lighter_${FILE_base}/Multicell/log $Out/Reports/Logs/Megahit_lighter.log
	cp $Out/Megahit_${FILE_base}/Trimmomatic_hard/Multicell/log $Out/Reports/Logs/Megahit_Trimmomatic.log
	cp $Out/Masurca_${FILE_base}/*.log $Out/Reports/Logs/
	cp $Out/SPAdes_${FILE_base}/Lighter_${FILE_base}/Multicell/Spades.log $Out/Reports/Logs/Spades_lighter.log
	cp $Out/SPAdes_${FILE_base}/Trimmomatic_hard/Multicell/Spades.log $Out/Reports/Logs/Spades_Trimmomatic.log
	cp $Out/ABySS_${FILE_base}/Lighter_${FILE_base}/${FILE_base}_abyss_final_summary.tsv $Out/Reports/Logs/ABySS_Lighter_final_summary.tsv
	cp $Out/ABySS_${FILE_base}/Trimmomatic_hard/${FILE_base}_abyss_final_summary.tsv $Out/Reports/Logs/ABySS_Trimmomatic_final_summary.tsv
	#KmerGenie
	cp $Out/KmerGenie_${FILE_base}/Lighter_${FILE_base}/best_k.txt $Out/Reports/KmerGenie/Lighter_${FILE_base}_best_k.txt
	cp $Out/KmerGenie_${FILE_base}/Lighter_${FILE_base}/genome_size.txt $Out/Reports/KmerGenie/Lighter_${FILE_base}_genome_size.txt
	cp $Out/KmerGenie_${FILE_base}/Trimmomatic_Adapters/best_k.txt $Out/Reports/KmerGenie/Trimmomatic_Adapters_best_k.txt
	cp $Out/KmerGenie_${FILE_base}/Trimmomatic_Adapters/genome_size.txt $Out/Reports/KmerGenie/Trimmomatic_Adapters_genome_size.txt
	cp $Out/KmerGenie_${FILE_base}/Trimmomatic_hard/best_k.txt $Out/Reports/KmerGenie/Trimmomatic_hard_best_k.txt
	cp $Out/KmerGenie_${FILE_base}/Trimmomatic_hard/genome_size.txt $Out/Reports/KmerGenie/Trimmomatic_hard_genome_size.txt
	#delete Trimmomatic's huge log files
	rm $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Trimmomatic.log
	rm $Out/Trimmomatic_${FILE_base}/Trimmomatic_Adapters/*Trimmomatic.log
	# start compressing the folders if statment: https://unix.stackexchange.com/questions/613357/checking-if-tar-file-exists-bash-script
	# this should be replaced with a neater foor loop along the folders....
	cd $Out
	if [ -f ABySS_${FILE_base}.tar.xz ]
	then
		echo "ABySS_${FILE_base}.tar.xz exist, skipping compression"
	else
		tar -cvf ABySS_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}' ABySS_${FILE_base} && rm -R ABySS_${FILE_base}
	fi
	
	if [ -f BUSCO.tar.xz ]
	then
		echo "BUSCO.tar.xz exist, skipping compression"
	else
		tar -cvf BUSCO.tar.xz --use-compress-program='xz -7T${Threads}' BUSCO && rm -R BUSCO # BUSCO might need in Blobtools?
	fi
	
	if [ -f FastQC_${FILE_base}.tar.xz ]
	then
		echo "FastQC_${FILE_base}.tar.xz, skipping compression"
	else
	tar -cvf FastQC_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}' FastQC_${FILE_base} && rm -R FastQC_${FILE_base}
	fi
	
	if [ -f IDBA_${FILE_base}.tar.xz ]
	then
		echo "IDBA_${FILE_base}.tar.xz, skipping compression"
	else	
	tar -cvf IDBA_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}' IDBA_${FILE_base} && rm -R IDBA_${FILE_base}
	fi
	
	if [ -f KAT_${FILE_base}.tar.xz ]
	then
		echo "KAT_${FILE_base}.tar.xz, skipping compression"
	else		
	tar -cvf KAT_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}' KAT_${FILE_base} && rm -R KAT_${FILE_base}
	fi
	
	if [ -f KmerGenie_${FILE_base}.tar.xz ]
	then
		echo "KmerGenie_${FILE_base}.tar.xz, skipping compression"
	else	
	tar -cvf KmerGenie_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}' KmerGenie_${FILE_base} && rm -R KmerGenie_${FILE_base}
	fi
	
	if [ -f Masurca_${FILE_base}.tar.xz ]
	then
		echo "Masurca_${FILE_base}.tar.xz, skipping compression"
	else	
	tar -cvf Masurca_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}' Masurca_${FILE_base} && rm -R Masurca_${FILE_base}
	fi
	
	if [ -f SPAdes_${FILE_base}.tar.xz ]
	then
		echo "SPAdes_${FILE_base}.tar.xz, skipping compression"
	else	
	tar -cvf SPAdes_${FILE_base}.tar.xz --use-compress-program='xz -7T${Threads}'  SPAdes_${FILE_base} && rm -R SPAdes_${FILE_base}
	fi
	
	if [ -f RawGenomesSamtoolsStat.tar.xz ]
	then
		echo "RawGenomesSamtoolsStat.tar.xz, skipping compression"
	else		
	tar -cvf RawGenomesSamtoolsStat.tar.xz --use-compress-program='xz -7T${Threads}' RawGenomesSamtoolsStat && rm -R RawGenomesSamtoolsStat #this folder could be usefull for blobtools..?
	fi
	
	if [ -f MultiQC.tar.xz ]
	then
		echo "MultiQC.tar.xz, skipping compression"
	else		
	tar -cvf MultiQC.tar.xz  --use-compress-program='xz -7T${Threads}' MultiQC && rm -R MultiQC 
	fi
	
	if [ -f Quast.tar.xz ]
	then
		echo "Quast.tar.xz, skipping compression"
	else		
	tar -cvf Quast.tar.xz  --use-compress-program='xz -7T${Threads}' Quast && rm -R Quast
	fi
	
	if [ -f Megahit_${FILE_base}.tar.xz ]
	then
		echo "Megahit_${FILE_base}.tar.xz, skipping compression"
	else	
	tar -cvf Megahit_${FILE_base}.tar.xz  --use-compress-program='xz -7T${Threads}' Megahit_${FILE_base} && rm -R Megahit_${FILE_base}
	fi
	
	#cd $PATH_Output; zip -r ${FILE_base}.zip ../${FILE_base}
fi
