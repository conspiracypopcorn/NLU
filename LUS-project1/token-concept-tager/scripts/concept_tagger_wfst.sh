#create wfst from words to concept tags.
lex=../output/lex.txt
conc_cnt=../output/concept.cnt
tok_conc_cnt=../output/token_concept.cnt
tok_conc_txt=../output/token_concept.txt
tok_conc_fst=../output/token_concept.fst
unk_conc_txt=../output/unknown_concept.txt
unk_conc_fst=../output/unknown_concept.fst
conc_tagger=../output/concept_tagger.fst

echo 'Creating states file for concept tagger...'
rm -f $tok_conc_fst
rm -f $tok_conc_txt

while read token conc count
do	
	#get concept counts
	conc_count=$(grep  -P "^$conc\t" $conc_cnt | cut -f 2)
	prob=$(echo "-l($count / $conc_count)" | bc -l)
	echo -e "0\t0\t$token\t$conc\t$prob" >> $tok_conc_txt
done < $tok_conc_cnt
echo "0" >> $tok_conc_txt

echo 'Compiling wfst...'
fstcompile --isymbols=$lex --osymbols=$lex $tok_conc_txt > $tok_conc_fst



#transducer for unknown words
echo 'Creating states file for unknown word tagger...'
rm -f $unk_conc_txt
prob=$(echo "-l(1/41)" | bc -l)
while read conc count
do
	echo -e "0\t0\t<unk>\t$conc\t$prob">>$unk_conc_txt
done < $conc_cnt
echo "0" >> $unk_conc_txt

echo 'Compiling wfst...'
fstcompile --isymbols=$lex --osymbols=$lex $unk_conc_txt > $unk_conc_fst


echo 'Making union and closure...'
fstunion $unk_conc_fst $tok_conc_fst | fstclosure > $conc_tagger
