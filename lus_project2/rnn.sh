#!/bin/bash

i=1

config_file=rnn_slu/config.cfg


models=(elman)
learning_rates=(0.1)
context_windows=(9)
hidden_sizes=(100)
embedding_sizes=(100)
nepochs=50

for arch in "${models[@]}"
do
	for lr in "${learning_rates[@]}"
	do
		for cw in "${context_windows[@]}"
		do
			for hidden_size in "${hidden_sizes[@]}"
			do
				for emb_size in "${embedding_sizes[@]}"
				do
					SECONDS=0
					echo "STARTING $i TRAINING"
					echo "CURRENT PARAMETERS:"
					echo -e "architecture: $arch\nlr: $lr\nwin: $cw\nbs: 10\nnhidden:$hidden_size\nseed: 3842845\nemb_dimension: $emb_size\nnepochs: $nepochs"
					folder="$arch"_"$cw"_"$lr"_"$emb_size"_"$hidden_size"
					echo $folder
					#create config file
					echo -e "lr: $lr\nwin: $cw\nbs: 10\nnhidden: $hidden_size\nseed: 3842845\nemb_dimension: $emb_size\nnepochs: $nepochs" > $config_file
					#run training storing cost and f1 for each iteration
					export PYTHONPATH=/home/giulio/Desktop/NLU/lus_rnn_lab1:$PYTHONPATH
					train_py=rnn_"$arch"_train.py
					test_py=rnn_"$arch"_test.py
					mkdir $folder
					python rnn_slu/lus/$train_py rnn_slu/data/train.txt rnn_slu/data/valid.txt rnn_slu/data/word_dict.txt rnn_slu/data/label_dict.txt rnn_slu/config.cfg $folder > $folder/epoch_f1_cost.txt
					#run test
					python rnn_slu/lus/$test_py $folder rnn_slu/data/NLSPARQL.test.data rnn_slu/data/word_dict.txt rnn_slu/data/label_dict.txt rnn_slu/config.cfg $folder/test_out.txt > $folder/a_p_r_f1.txt
					#save all in a folder
					i=$((i+1))
					echo -e "elapsed: $SECONDS s"
					echo -e "elapsed: $SECONDS" >> $folder/a_p_r_f1.txt
				done
			done
		done
	done
done
