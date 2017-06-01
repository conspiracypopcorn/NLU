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
    if (len(sys.argv) < 6):
        print "Usage: " +  sys.argv[0] + " <train_file> <valid_file> <word_dictionary> <label_dictionary> <config_file> <model_directory>"
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

#Read Training Data and Create Dictionaries
    train_lex=[]
    train_ne=[]
    train_y = []
    temp_lex = []
    temp_ne = []
    temp_y = []
    train_file = open(sys.argv[1], "r")
    for line in train_file:
        if line in ['\n', '\r\n']:
            if len(temp_lex) > 0:
                train_lex.append(temp_lex)
                train_ne.append(temp_ne)
                train_y.append(temp_y)
                temp_lex=[]
                temp_ne=[]
                temp_y=[]
            continue
        token,label=line.split()
        if token in words2idx.keys():
                temp_lex.append(words2idx[token])
        else:
                temp_lex.append(words2idx["<UNK>"])
        temp_ne.append(0)
        if label in labels2idx.keys():
                temp_y.append(labels2idx[label])
        else:
                temp_y.append(labels2idx["<UNK>"])

#Read the validation file
    valid_lex=[]
    valid_ne=[]
    valid_y = []
    temp_lex = []
    temp_ne = []
    temp_y = []
    valid_file = open(sys.argv[2], "r")
    for line in valid_file:
        if line in ['\n', '\r\n']:
            if len(temp_lex) > 0:
                valid_lex.append(temp_lex)
                valid_ne.append(temp_ne)
                valid_y.append(temp_y)
                temp_lex=[]
                temp_ne=[]
                temp_y=[]
            continue
        token,label=line.split()
        if token in words2idx.keys():
                temp_lex.append(words2idx[token])
        else:
                temp_lex.append(words2idx["<UNK>"])
        temp_ne.append(0)
        if label in labels2idx.keys():
                temp_y.append(labels2idx[label])
        else:
                temp_y.append(labels2idx["<UNK>"])



    folder = os.path.basename(sys.argv[6])
    if not os.path.exists(folder): os.mkdir(folder)
    s = {'lr':0.0627142536696559,
         'verbose':0,
         'decay':True, # decay on the learning rate if improvement stops
         'win':7, # number of words in the context window
         'bs':9, # mini-batch size
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
    nsentences = len(train_lex)


    # instanciate the model
    numpy.random.seed(s['seed'])
    random.seed(s['seed'])
    rnn = model(    nh = s['nhidden'],
                    nc = nclasses,
                    ne = vocsize,
                    de = s['emb_dimension'],
                    cs = s['win'] )

    # train with early stopping on validation set
    best_f1 = -numpy.inf
    s['clr'] = s['lr']
    for e in xrange(s['nepochs']):
        # shuffle
        shuffle([train_lex, train_y], s['seed'])
        s['ce'] = e
        tic = time.time()
        total_cost = 0
        count = 0
        for i in xrange(nsentences):
            cwords = contextwin(train_lex[i], s['win'])
            words  = map(lambda x: numpy.asarray(x).astype('int32'),\
                         minibatch(cwords, s['bs']))
            labels = train_y[i]
            for word_batch , label_last_word in zip(words, labels):
                total_cost += rnn.train(word_batch, label_last_word, s['clr'])
                count +=1
                rnn.normalize()
            if s['verbose']:
                print '[learning] epoch %i >> %2.2f%%'%(e,(i+1)*100./nsentences),'completed in %.2f (sec) <<\r'%(time.time()-tic),
                sys.stdout.flush()
        #print ''
        #print 'Learning rate: %2.4f'%(s['clr'])
        #print 'Average Training Cost: %2.4f'%(total_cost/count)

        predictions_valid = [ map(lambda x: idx2label[x], \
                             rnn.classify(numpy.asarray(contextwin(x, s['win'])).astype('int32')))\
                             for x in valid_lex ]
        groundtruth_valid = [ map(lambda x: idx2label[x], y) for y in valid_y ]
        words_valid = [ map(lambda x: idx2word[x], w) for w in valid_lex]
        res_valid = conlleval(predictions_valid, groundtruth_valid, words_valid, folder + '/current.valid.txt')

        if res_valid['f1'] > best_f1:
            rnn.save(folder)
            best_f1 = res_valid['f1']
            if s['verbose']:
                print 'NEW BEST: epoch', e, 'valid F1', res_valid['f1'], ' '*20
            s['vf1'], s['vp'], s['vr'] = res_valid['f1'], res_valid['p'], res_valid['r']
            s['be'] = e
            subprocess.call(['mv', folder + '/current.valid.txt', folder + '/best.valid.txt'])
        print e, " ", res_valid['f1'], ' %2.4f'%(total_cost/count)

        # learning rate decay if no improvement in 10 epochs
        if s['decay'] and abs(s['be']-s['ce']) >= 10: s['clr'] *= 0.5
        #if s['clr'] < 1e-5: break

    #print 'BEST RESULT: epoch', e, 'valid F1', s['vf1'], 'with the model', folder
