import numpy
import time
import sys
import subprocess
import os
import random

from rnn_slu.rnn.jordan import model
from rnn_slu.metrics.accuracy import conlleval
from rnn_slu.utils.tools import shuffle, minibatch, contextwin

if __name__ == '__main__':
    if (len(sys.argv) < 7):
        print "Usage: " +  sys.argv[0] + " <model_directory> <test_file> <word_dictionary> <label_dictionary> <config_file> <output_file>"
        sys.exit(0)

#Read word dict
    words2idx={}
    word_dict = open(sys.argv[3], "r")
    for line in word_dict:
        key,val=line.split()
        words2idx[key] = int(val)
    idx2word  = dict((k,v) for v,k in words2idx.iteritems())

#Read label dict
    labels2idx={}
    label_dict = open(sys.argv[4], "r")
    for line in label_dict:
        key,val=line.split()
        labels2idx[key] = int(val)
    idx2label = dict((k,v) for v,k in labels2idx.iteritems())

#Read Test Data
    test_lex=[]
    test_y = []
    temp_lex = []
    temp_y = []
    test_file = open(sys.argv[2], "r")
    for line in test_file:
        if line in ['\n', '\r\n']:
            if len(temp_lex) > 0:
                test_lex.append(temp_lex)
                test_y.append(temp_y)
                temp_lex=[]
                temp_y=[]
            continue
        token,label=line.split()
        if token in words2idx.keys():
                temp_lex.append(words2idx[token])
        else:
                temp_lex.append(words2idx["<UNK>"])
        if label in labels2idx.keys():
                temp_y.append(labels2idx[label])
        else:
                temp_y.append(labels2idx["<UNK>"])



    folder = os.path.basename(sys.argv[1])
    s = {'lr':0.0627142536696559,
         'verbose':1,
         'decay':False, # decay on the learning rate if improvement stops
         'win':7, # number of words in the context window
         'bs':10, # mini-batch size
         'nhidden':100, # number of hidden units
         'seed':345,
         'emb_dimension':100, # dimension of word embedding
         'nepochs':10}

    config_file = open(sys.argv[5], "r")
    for line in config_file:
        param,val=line.split()
        if param == "lr:":
            s['lr'] = float(val)
        elif param == "win:":
            s['win'] = int(val)
        elif param == "bs:":
            s['bs'] = int(val)
        elif param == "nhidden:":
            s['nhidden'] = int(val)
        elif param == "seed:":
            s['seed'] = int(val)
        elif param == "emb_dimension:":
            s['emb_dimension'] = int(val)
        elif param == "nepochs:":
            s['nepochs'] = int(val)

    vocsize = len(words2idx)
    nclasses = len(labels2idx)
    nsentences = len(test_lex)

    numpy.random.seed(s['seed'])
    random.seed(s['seed'])
    rnn = model(    nh = s['nhidden'],
                    nc = nclasses,
                    ne = vocsize,
                    de = s['emb_dimension'],
                    cs = s['win'] )
    rnn.load(folder)

    predictions_test = [ map(lambda x: idx2label[x], \
                             rnn.classify(numpy.asarray(contextwin(x, s['win'])).astype('int32')))\
                             for x in test_lex ]
    groundtruth_test = [ map(lambda x: idx2label[x], y) for y in test_y ]
    words_test = [ map(lambda x: idx2word[x], w) for w in test_lex]
    res_test = conlleval(predictions_test, groundtruth_test, words_test, sys.argv[6])

    #print 'Test set performance -- F1: ', res_test['f1'], ' '*20
    print res_test['a'],' ',res_test['p'],' ',res_test['r'],' ',res_test['f1'],' '
