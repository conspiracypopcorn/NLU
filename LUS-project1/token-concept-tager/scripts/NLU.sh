#!/bin/bash

smoothing="witten_bell" #smooting techniques: witten_bell absolute katz kneser_ney presmoothed unsmoothed
order=3 #ngram order

SECONDS=0

./lex.sh
./counts.sh
./concept_tagger_wfst.sh
./train_lm.sh $smoothing $order
./evaluate.sh
echo "Time elapsed: $SECONDS seconds"

./create_conlleval_file.sh

