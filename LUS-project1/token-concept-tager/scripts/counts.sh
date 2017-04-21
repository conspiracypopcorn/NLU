#concept count file

#create count file for the tags C(ti)
data=../data/NLSPARQL.train.data
conc_cnt=../output/concept.cnt
tok_conc_cnt=../output/token_concept.cnt

rm -f $conc_cnt
rm -f $tok_conc_cnt

echo 'Creating concept count file...'
cat $data | cut -f 2 |\
#delete empty lines
sed '/^ *$/d'|\
#sort and count
sort | uniq -c|\
#eliminate initial spaces
sed 's/^ *//g' |\
#swap columns
awk '{OFS="\t"; print $2,$1}' > $conc_cnt

echo 'Creating joint occurence count file...'
#create  count file for joint occurence tag word C(ti,wi)
cat $data |\
sed '/^ *$/d' |\
sort | uniq -c |\
sed 's/^ *//g' |\
awk '{OFS="\t"; print $2, $3, $1}' > $tok_conc_cnt
#co-occurrence word-concept count file
