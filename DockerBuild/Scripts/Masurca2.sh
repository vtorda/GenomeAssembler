#!/bin/bash
echo "Masurca is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
INPUT=$1
Folder=$(echo $INPUT | awk -F '/' '{print $NF}')
KmerGenie=$Out/KmerGenie_${FILE_base}/${Folder}
bestk=$(cat $KmerGenie/best_k.txt)
genome_s=$(cat $KmerGenie/genome_size.txt)
mkdir -p $Out/Masurca_${FILE_base}
OutputDir_auto=$Out/Masurca_${FILE_base}/${Folder}_kauto
OutputDir_genie=$Out/Masurca_${FILE_base}/${Folder}_kmergenie
mkdir -p $OutputDir_auto
mkdir -p $OutputDir_genie

for f in $INPUT/*.fastq.gz; do gzip -d -k $f -c > $OutputDir_genie/$(echo ${f//.gz} | awk -F '/' '{print $NF}'); done
for f in $INPUT/*.fastq.gz; do gzip -d -k $f -c > $OutputDir_auto/$(echo ${f//.gz} | awk -F '/' '{print $NF}'); done

Rscript /home/repl/Scripts/Masurca_init2.R $INPUT $Threads $genome_s $bestk $OutputDir_genie > $OutputDir_genie/Rscript_init.outlog 2> $OutputDir_genie/Rscript_init.error
Rscript /home/repl/Scripts/Masurca_init2.R $INPUT $Threads $genome_s auto $OutputDir_auto > $OutputDir_auto/Rscript_init.outlog 2> $OutputDir_auto/Rscript_init.error
echo "Analysis of ${Folder} fastq libraries kmer size is based on KmerGenie"
cd $OutputDir_genie
masurca config.txt
#there was a memory issue at the gap closer step so I found here that I can change this parameter: https://github.com/alekseyzimin/masurca/issues/122
sed -i -e "s/memory 1000000000/memory 100000000/g" $OutputDir_genie/assemble.sh 
bash assemble.sh
wait
cp ${OutputDir_genie}/CA/primary.genome.scf.fasta ${OutputDir_genie}/CA/Masurca_${FILE_base}_${Folder}_kmergenie.scaffolds.fa
echo ${OutputDir_genie}/CA/Masurca_${FILE_base}_${Folder}_kmergenie.scaffolds.fa >> $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt
## deleting some files that I hope I won't miss
if [ $LowStorage = 1]
then
	rm *.fastq quorum_mer_db.jf pe.cor.fa k_u_hash_0 superReadSequences_shr.frg unitig_layout.txt unitig_cov.txt 
fi
echo "Analysis of ${Folder} fastq libraries kmer size is based on Masurca's estimation"
cd $OutputDir_auto
masurca config.txt
#there was a memory issue at the gap closer step so I found here that I can change this parameter: https://github.com/alekseyzimin/masurca/issues/122
sed -i -e "s/memory 1000000000/memory 100000000/g" $OutputDir_auto/assemble.sh 
bash assemble.sh
wait
cp ${OutputDir_auto}/CA/primary.genome.scf.fasta ${OutputDir_auto}/CA/Masurca_${FILE_base}_${Folder}_auto.scaffolds.fa
echo ${OutputDir_auto}/CA/Masurca_${FILE_base}_${Folder}_auto.scaffolds.fa >> $Out/Masurca_${FILE_base}/Masurca_scaffolds_to_anal.txt
if [ $LowStorage = 1]
then
rm *.fastq quorum_mer_db.jf pe.cor.fa k_u_hash_0 superReadSequences_shr.frg unitig_layout.txt unitig_cov.txt 
fi