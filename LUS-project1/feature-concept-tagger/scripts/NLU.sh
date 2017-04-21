#!/bin/bash

smoothing="witten_bell" #smooting techniques: witten_bell absolute katz kneser_ney presmoothed unsmoothed
order=5 #ngram order
feature=1 #feature=1 for POS; feature=2 for lemmas

SECONDS=0

./lex.sh $feature
./counts.sh
./concept_tagger_wfst.sh
./train_lm.sh $smoothing $order
./evaluate.sh $feature
echo "Time elapsed: $SECONDS seconds"

./create_conlleval_file.sh

