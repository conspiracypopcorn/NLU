#!/bin/bash

feat_train=../output/feat.train.data
lex=../output/lex.txt
train_conc_sent=../output/train_concept_sentence.txt
train_conc_far=../output/train_concept.far
conc_ngram_cnt=../output/concept_ngram.cnt
conc_lm=../output/concept.lm

#convert token per line into sentence per line
echo "Converting token per line into sentence per line..."
rm -f $train_conc_sent

cat $feat_train | cut -f2 |\
#replace empty line with special symbol
sed 's/^ *$/#/g' |\
#replace \n with space
tr '\n' ' '|\
#replace # with \n
tr '#' '\n'|\
#clean redundant spaces
sed 's/^ *//g;s/ *$//g' > $train_conc_sent

#create language model with trigram
echo "Training language model (Smoothing $1, Order $2)"
farcompilestrings --symbols=$lex -keep_symbols=1 --unknown_symbol='<unk>' $train_conc_sent > $train_conc_far
ngramcount --order=$2 $train_conc_far > $conc_ngram_cnt
ngrammake --method=$1 $conc_ngram_cnt > $conc_lm
