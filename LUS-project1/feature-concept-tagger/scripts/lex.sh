#!/bin/bash
data=../data/NLSPARQL.train.data
feats=../data/NLSPARQL.train.feats.txt
feat_train=../output/feat.train.data
lex=../output/lex.txt
#create lexicon
mkdir ../output
rm -f $lex
echo "Creating lexicon..."
echo -e "<epsilon>\t0">>$lex
i=1

##with frequency cutoff
#cat $data | tr -s " \t" "\n" | sed '/^ *$/d' | sort | uniq -c | awk '$1>1 {print $2}' > a.tmp
if [ $1 -eq 1 ]; then
	column=2
else
	column=3
fi

cat $feats | cut -f$column > tmp1 #cut -f3 for lemmas

cat $data | cut -f2 > tmp2

paste tmp1 tmp2 > $feat_train

rm -f tmp1
rm -f tmp2

#without frequency cutoff
cat $feat_train | tr -s " \t" "\n" | sed '/^ *$/d' | sort | uniq > a.tmp

while read token
do
	echo -e "$token\t$i">>$lex
	i=$((i+1))
done < a.tmp
rm a.tmp

echo -e "<unk>\t$i">>$lex




