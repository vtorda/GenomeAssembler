#!/bin/sh
# $1 is a base name of fastq files
# $2 is the thread number
FILES=/home/repl/Input/$1*
for f in ${FILES}
	do
		fastqc $f -o /home/repl/Output -t $2
		wait
	done









