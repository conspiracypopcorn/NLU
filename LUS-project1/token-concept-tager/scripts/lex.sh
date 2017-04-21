#!/bin/bash
data=../data/NLSPARQL.train.data
lex=../output/lex.txt
mkdir ../output
#create lexicon
rm -f $lex
echo "Creating lexicon..."
echo -e "<epsilon>\t0">>$lex
i=1

##with frequency cutoff
#cat $data | tr -s " \t" "\n" | sed '/^ *$/d' | sort | uniq -c | awk '$1>1 {print $2}' > a.tmp

#without frequency cutoff
cat $data | tr -s " \t" "\n" | sed '/^ *$/d' | sort | uniq > a.tmp

while read token
do
	echo -e "$token\t$i">>$lex
	i=$((i+1))
done < a.tmp
rm a.tmp

echo -e "<unk>\t$i">>$lex




