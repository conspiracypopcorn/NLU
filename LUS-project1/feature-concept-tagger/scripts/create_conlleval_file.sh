#!/bin/bash
test_data=../data/NLSPARQL.test.data
test_feats_data=../data/NLSPARQL.test.feats.txt
full_test_tags=../output/full_test_tags.txt
conlleval_file=../output/conlleval_file.txt
tmp1=../output/tmp1.txt
tmp2=../output/tmp2.txt

paste $test_data $full_test_tags > $tmp1

cat $test_feats_data | cut -f2 > $tmp2

paste $tmp1 $tmp2 | awk '{OTF='\t'; print $1, $4, $2, $3 }'> $conlleval_file

rm -f $tmp1
rm -f $tmp2

./conlleval.pl < $conlleval_file


