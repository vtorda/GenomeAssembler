#!/bin/sh
# following the idea of https://www.biostars.org/p/243552/
Out=$PATH_Output/$FILE_base
Input=$1
Folder=$(echo $Input | awk -F '/' '{print $NF}')

all_files=$(ls -d $Input/*fastq.gz)
Paired=$(echo "$all_files" | grep Pair)
#Single=$(echo "$all_files" | grep Single)


echo $(echo "$Paired" | awk -F '/' '{print $NF}') $(awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("PairedRead total %d avg=%f stddev=%f\n",n,m,sqrt(sq/n-m*m));}' $Paired) >> $Input/${Folder}_${FILE_base}_readstat.txt

for F in $all_files
do
echo $(echo $F | awk -F '/' '{print $NF}') $(awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("SingleRead total %d avg=%f stddev=%f\n",n,m,sqrt(sq/n-m*m));}' $F)
done >> $Input/${Folder}_${FILE_base}_readstat.txt


