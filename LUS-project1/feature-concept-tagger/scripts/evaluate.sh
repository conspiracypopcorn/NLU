#!/bin/bash

test_data=../data/NLSPARQL.test.feats.txt
lex=../output/lex.txt
test_sent=../output/test_sentence.txt
conc_tagger=../output/concept_tagger.fst
conc_lm=../output/concept.lm
test_tagged_far=../output/test_tagged.far
sent_txt=../output/sent.txt
sent_fst=sent.txt-1
full_test_tags=../output/full_test_tags.txt

rm -f $full_test_tags

#convert token per line into sentence per line
echo "Converting test set into sentence per line..."
# f2 pos f3 lemma
if [ $1 -eq 1 ]; then
	column=2
else
	column=3
fi

cat $test_data | cut -f$column | sed 's/^ *$/#/g' | tr '\n' ' '| tr '#' '\n'| sed 's/^ *//g;s/ *$//g' > $test_sent

	

i=0
echo "Tagging test set..."

while read line
do	
	./text2fst.sh "$line" > $sent_txt
	fstcompile --isymbols=$lex --osymbols=$lex $sent_txt > $sent_fst
	fstcompose $sent_fst $conc_tagger | fstcompose - $conc_lm | fstrmepsilon | fstshortestpath | fsttopsort > $test_tagged_far
	fstprint --isymbols=$lex --osymbols=$lex $test_tagged_far | cut -f4 | tr '[0-9]' ' ' >> $full_test_tags
	i=$((i+1))
	if [ $(($i%100)) -eq 0 ]
		then echo "Tagged sentences: $i"
    	fi
done < $test_sent

rm -f $sent_txt
rm -f $sent_fst



