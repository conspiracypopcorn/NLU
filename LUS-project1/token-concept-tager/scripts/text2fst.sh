#! /bin/bash
#read input string from STDIN
lex=../output/lex.txt
str=$1
#parse it into array using space as separator
arr=$(echo $str | tr ' ' '\n')
#set initial state
state=0
#iterate through array
#printing current and next states & token
for token in ${arr[@]}
do
	if ! grep -Pq "^$token\t" $lex; then
	token='<unk>'
	fi
	echo -e "$state\t$((state + 1))\t$token\t$token"
	#increment state
	((state++))
done
#print final state
echo $state
