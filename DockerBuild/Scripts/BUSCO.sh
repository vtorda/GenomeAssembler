#!/bin/bash
echo "BUSCO is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Folder=$1
Pattern=$2
if [ $Polish = 1 ]
	then
	Folder2="${Pattern//.fasta}"
fi
if [ $Polish != 1 ]
	then
	Folder2="${Pattern//.fa}"
fi
Dir=$Out/BUSCO
mkdir -p $Dir
OutputDir=$Out/BUSCO/$Folder2
mkdir -p $OutputDir
files=$(ls -d ${Folder}/*${Pattern})
mkdir -p $Out/BUSCO/$Folder2/Summary_files
for genomes in ${files}; do
	NAME=$(echo $genomes | awk -F '/' '{print $NF}')
	#echo $NAME
	NAME=$(echo $NAME | sed 's/.scaffolds.fa_polished.fasta//g')
	echo $NAME
	Out2=$Out/BUSCO/$Folder2/$NAME
	mkdir -p $Out2
	busco -c $Threads -i $genomes -l $odb -m genome -o $NAME -f --out_path $Out/BUSCO/$Folder2 > $Out/BUSCO/$Folder2/Busco_$NAME.log 2> $Out/BUSCO/$Folder2/Busco_$NAME.elog
	cp $Out/BUSCO/$Folder2/$NAME/short_summary*.txt $Out/BUSCO/$Folder2/Summary_files/
done
