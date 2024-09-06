#!/bin/bash
# --no-sv : https://github.com/ablab/quast/issues/235

echo "Quast is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Folder=$1
Pattern=$2
if [ $Polish = 1 ]
	then
	Pattern2=$(echo $Pattern | sed 's/.fasta//g')
fi
if [ $Polish != 1 ]
	then
	Pattern2=$(echo $Pattern | sed 's/.fa//g')
fi

Dir=$Out/Quast
mkdir -p $Dir
OutputDir=$Out/Quast/$Pattern2
mkdir -p $OutputDir
mkdir -p $OutputDir/Reports
mkdir -p $OutputDir/Reports/Lighter
mkdir -p $OutputDir/Reports/Trimmomatic
files=$(ls -d ${Folder}/*${Pattern})
#generate label names
delim=""
NAME=""
for p in ${files}
do
	NAME_temp=$(echo $p | awk -F '/' '{print $NF}')
	NAME_temp2=$(echo $NAME_temp | sed 's/.scaffolds.fa_polished_filtered.fasta//g')
	NAME_temp3=${NAME_temp2}
	NAME="$NAME$delim$NAME_temp3"
	delim=", "
done

Out2=$Out/Quast/$Pattern2/Lighter
mkdir -p $Out2
quast.py -o $Out2 -l "$NAME" ${files} --threads $Threads --fungus --k-mer-stats --glimmer --rna-finding $ReportAll --plots-format png --min-contig 200 --circos \
		$AddArgs --pe1 $Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz --pe2 $Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz
# copy and rename report tsv
cp $Out2/report.tsv $OutputDir/Reports/Lighter/

if [ Quast_trimmom != 1 ]
then
	#generate label names
	delim=""
	NAME=""
	for p in ${files}
	do
		NAME_temp=$(echo $p | awk -F '/' '{print $NF}')
		NAME_temp2=$(echo $NAME_temp | sed 's/.scaffolds.fa_polished_filtered.fasta//g')
		NAME_temp3=${NAME_temp2}
		NAME="$NAME$delim$NAME_temp3"
		delim=", "
	done

	Out2=$Out/Quast/$Pattern2/Trimmomatic
	mkdir -p $Out2
	quast.py -o $Out2 -l "$NAME" ${files} --threads $Threads --fungus --k-mer-stats --glimmer --rna-finding $ReportAll --plots-format png --min-contig 200 --circos \
			$AddArgs --pe1 $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz --pe2 $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz \
			--single $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_1.fastq.gz --single $Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Single_2.fastq.gz
	# copy and rename report tsv
	cp $Out2/report.tsv $OutputDir/Reports/Trimmomatic
fi