#!/bin/bash

data=NLSPARQL.train.data

word_dict=word_dict.txt
label_dict=label_dict.txt
train_set=train.txt
valid_set=valid.txt

rm -f $word_dict
rm -f $label_dict
rm -f $valid_set
rm -f $train_set

#create validation set
i=0
while read line
do
	if [[  $(( i % 5 )) == 0 ]] ; then
		echo -e $line >> $valid_set
	else
		echo -e $line >> $train_set
	fi
	
	if [ "$line" == "" ]; then
		i=$((i+1))
	fi
done < $data

#freq cutoff
cat $train_set | tr " " "\t" | sed '/^ *$/d' | cut -f1 | sort | uniq -c | awk '$1>1 {print $2}' > token.tmp

#cat $train_set | tr " " "\t" | sed '/^ *$/d' | cut -f1 | sort | uniq > token.tmp

i=0
while read token
do
	echo -e "$token\t$i">>$word_dict
	i=$((i+1))
done < token.tmp
echo -e "<UNK>\t$i">>$word_dict
rm token.tmp

cat $train_set | tr " " "\t" | sed '/^ *$/d' | cut -f2 | sort | uniq > label.tmp

i=0
while read label
do
	echo -e "$label\t$i">>$label_dict
	i=$((i+1))
done < label.tmp
echo -e "<UNK>\t$i">>$label_dict
rm label.tmp
