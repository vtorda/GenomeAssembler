#!/bin/bash
echo "Pilon is started, time: $(date +"%T")"
Out=$PATH_Output/$FILE_base
Trimmomatic_files=$(grep Trimmo ${Out}/All_raw_scaffolds.fasta)
Lighter_files=$(grep Lighter ${Out}/All_raw_scaffolds.fasta)

OutputDir=$Out/Polished_genomes
mkdir -p $OutputDir
mkdir -p $OutputDir/Polished_genomes_final
mkdir -p $OutputDir/Polished_genomes_stat
#Set input and parameters
round=$NextPolishRounds
#threads=20

source activate busco
# lighter
for scaffold in $Lighter_files; do
	read1=$Out/Lighter_${FILE_base}/*Pair_1*.fastq.gz
	read2=$Out/Lighter_${FILE_base}/*Pair_2*.fastq.gz
	input=$scaffold
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}
	for ((i=1; i<=${round}; i++)); do
	#step 1:
	   #index the genome file and do alignment
	   bwa index ${input};
	   bwa mem -t ${Threads} ${input} ${read1} ${read2} | samtools view --threads 3 -F 0x4 -b - | samtools fixmate -m --threads 3 - -|samtools sort -m 2g --threads 5 - | samtools markdup --threads 5 -r - $OutputDir/${name}/${name}_sgs.sort.bam
	   #index bam and genome files
	   
	   samtools index -@ ${Threads} $OutputDir/${name}/${name}_sgs.sort.bam;
	   samtools faidx ${input};
	   #conda deactivate
	   #polish genome file
	   #python NextPolish/lib/nextpolish1.py -g ${input} -t 1 -p ${Threads}  -s $OutputDir/${name}/${name}_sgs.sort.bam > $OutputDir/${name}/${name}_polished.fasta;
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 1 -p ${Threads}  -s $OutputDir/${name}/${name}_sgs.sort.bam > $OutputDir/${name}/${name}_polished_temp.fasta;
	   input=$OutputDir/${name}/${name}_polished_temp.fasta;
	#step2:
	   #index genome file and do alignment
	   bwa index ${input};
	   bwa mem -t ${Threads} ${input} ${read1} ${read2} | samtools view --threads 3 -F 0x4 -b - | samtools fixmate -m --threads 3 - - | samtools sort -m 2g --threads 5 -| samtools markdup --threads 5 -r - $OutputDir/${name}/${name}_sgs.sort.bam
	   #index bam and genome files
	   #conda activate busco
	   samtools index -@ ${Threads} $OutputDir/${name}/${name}_sgs.sort.bam;
	   samtools faidx ${input};
	   #conda deactivate
	   #polish genome file
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 2 -p ${Threads}  -s $OutputDir/${name}/${name}_sgs.sort.bam > $OutputDir/${name}/${name}_polished.fasta;
	   input=$OutputDir/${name}/${name}_polished.fasta;
	done;
	# copy final genomes to a new folder 
	cp $OutputDir/${name}/${name}_polished.fasta $OutputDir/Polished_genomes_final/
	
	# move all intermediate files into a new subfolder
	Polishing_files=$OutputDir/${name}/Polishing_files
	mkdir -p $Polishing_files
	mv $OutputDir/${name}/* $Polishing_files
	cp $OutputDir/Polished_genomes_final/${name}_polished.fasta $OutputDir/${name}/

	#calculate new statistics
	genome=$OutputDir/${name}/${name}_polished.fasta
	bwa index $genome && bwa mem -t $Threads $genome ${read1} ${read2} | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted_polished.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted_polished.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted_polished.bam > $OutputDir/${name}/${name}_mapped_sorted_polished.stat
	# copy stat file into one folder for multiqc
	cp $OutputDir/${name}/${name}_mapped_sorted_polished.stat $OutputDir/Polished_genomes_stat/
done

for scaffold in $Trimmomatic_files; do
	read1=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_1.fastq.gz
	read2=$Out/Trimmomatic_${FILE_base}/Trimmomatic_hard/*Paired_2.fastq.gz
	input=$scaffold
	name=$(echo $scaffold | awk -F '/' '{print $NF}')
	# create an own folder for each
	mkdir -p $OutputDir/${name}
	for ((i=1; i<=${round}; i++)); do
	#step 1:
	   #index the genome file and do alignment
	   bwa index ${input};
	   bwa mem -t ${Threads} ${input} ${read1} ${read2}|samtools view --threads 3 -F 0x4 -b -|samtools fixmate -m --threads 3  - -|samtools sort -m 2g --threads 5 -|samtools markdup --threads 5 -r - $OutputDir/${name}/${name}_sgs.sort.bam
	   #index bam and genome files
	   samtools index -@ ${Threads} $OutputDir/${name}/${name}_sgs.sort.bam;
	   samtools faidx ${input};
	   #polish genome file
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 1 -p ${Threads}  -s $OutputDir/${name}/${name}_sgs.sort.bam > $OutputDir/${name}/${name}_polished_temp.fasta;
	   input=$OutputDir/${name}/${name}_polished_temp.fasta;
	#step2:
	   #index genome file and do alignment
	   bwa index ${input};
	   bwa mem -t ${Threads} ${input} ${read1} ${read2}|samtools view --threads 3 -F 0x4 -b -|samtools fixmate -m --threads 3  - -|samtools sort -m 2g --threads 5 -|samtools markdup --threads 5 -r - $OutputDir/${name}/${name}_sgs.sort.bam
	   #index bam and genome files
	   samtools index -@ ${Threads} $OutputDir/${name}/${name}_sgs.sort.bam;
	   samtools faidx ${input};
	   #polish genome file
	   python /usr/local/miniconda3/share/nextpolish-1.4.1/lib/nextpolish1.py -g ${input} -t 2 -p ${Threads}  -s $OutputDir/${name}/${name}_sgs.sort.bam > $OutputDir/${name}/${name}_polished.fasta;
	   input=$OutputDir/${name}/${name}_polished.fasta;
	done;
	# copy final genomes to a new folder 
	cp $OutputDir/${name}/${name}_polished.fasta $OutputDir/Polished_genomes_final/
	
		# move all intermediate files into a new subfolder
	Polishing_files=$OutputDir/${name}/Polishing_files
	mkdir -p $Polishing_files
	mv $OutputDir/${name}/* $Polishing_files
	cp $OutputDir/Polished_genomes_final/${name}_polished.fasta $OutputDir/${name}/
	
	#calculate new statistics
	genome=$OutputDir/${name}/${name}_polished.fasta
	bwa index $genome && bwa mem -t $Threads $genome ${read1} ${read2} | \
	samtools fixmate -u -m -@ ${Threads} - - | samtools sort -u -@ ${Threads} - | \
	samtools markdup -@ ${Threads} - $OutputDir/${name}/${name}_mapped_sorted_polished.bam && samtools index $OutputDir/${name}/${name}_mapped_sorted_polished.bam
	samtools flagstat $OutputDir/${name}/${name}_mapped_sorted_polished.bam > $OutputDir/${name}/${name}_mapped_sorted_polished.stat
	# copy stat file into one folder for multiqc
	cp $OutputDir/${name}/${name}_mapped_sorted_polished.stat $OutputDir/Polished_genomes_stat/
done
conda deactivate