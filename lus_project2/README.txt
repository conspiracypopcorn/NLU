This project allows to train a series of RNNs by setting the values of the hyperparameters. The value ranges can be set by editing the first few lines in the the file rnn.sh. It is possible to select: architecture (Elman,Jordan), learning rate, coxtext window size, hidden layer size and embedding size. Each model will be stored in a separate folder named: architecture_contextWin_learningRate_hiddenSize_embeddingSize.

After the training, the performance of the RNN will be evaluated on the training set and the resulting accuracy, precision, recall and F1 will be stored in the file a_p_r_f1.txt, together with the total training time.

USAGE:
-cd path/where/rnn.sh/is
-edit the desired parameters in rnn.sh
-./rnn.sh
