token-concept-tagger: 

this script allow to train a language model with the NLSPARQL data set and automatically evaluate its performance using conlleval. All the output data, including the language model file will be collected in the output folder.

Usage:

cd ../token-concept-tagger/scripts

nano NLU.sh (edit the first 2 lines to select smoothing and Ngram order)

./NLU.sh



feature-concept-tagger: 

this script allows to train a language model with NLSPARQL data set and automatically evaluate its performance using conlleval. It is possible to use POS tags or lemmas, by selecting feature argument. All the output data, including the language model file will be collected in the output folder.

Usage:

cd ../feature-concept-tagger/scripts

nano NLU.sh (edit the first 3 lines to select smoothing, Ngram order, feature)

./NLU.sh smoothing_method ngram_order feature
