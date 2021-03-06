#!/bin/bash

for file in *.gbk; do
	perl gb2bed.pl -i $file -k gene -o `basename $file .gbk`_raw.genes
	awk '($2 < $3)' `basename $file .gbk`_raw.genes > `basename $file .gbk`.genes
	#if first position is larger than second 
	#(e.g. origin, starting at the end of the file and ending at the start of the file), the record is excluded
	echo -e "`basename $file .gbk`\t$(grep "LOCUS" $file | sed 's/\s */\t/g' | cut -f3)" > `basename $file .gbk`.genome
	bedtools getfasta -fi `basename $file .gbk`.fasta -bed `basename $file .gbk`.genes > `basename $file .gbk`.genes.fas
	bedtools complement -i `basename $file .gbk`.genes -g `basename $file .gbk`.genome > `basename $file .gbk`.inter
	bedtools getfasta -fi `basename $file .gbk`.fasta -bed `basename $file .gbk`.inter >  `basename $file .gbk`.inter.fas
	cat `basename $file .gbk`.genes.fas `basename $file .gbk`.inter.fas | perl seq-shuf.pl > `basename $file .gbk`_shuf.fas
	echo ">`basename $file .gbk`_shuf" > `basename $file .gbk`_shuf_fake.fasta
	grep -v "^>" `basename $file .gbk`_shuf.fas | awk 'BEGIN { ORS="";} { print }' >> `basename $file .gbk`_shuf_fake.fasta
	echo -e "\n" >> `basename $file .gbk`_shuf_fake.fasta
done
mkdir fake_genomes
mv *fake.fasta fake_genomes

