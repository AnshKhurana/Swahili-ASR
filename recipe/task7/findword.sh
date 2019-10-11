cd ..
. ./path.sh

for i in exp/tri1/ali.*.gz; do
    ali-to-phones --ctm-output exp/tri1/final.mdl \
    ark:"gunzip -c $i|" -> ${i%.gz}.ctm 2> /dev/null;
done;

cat exp/tri1/*.ctm > task7/merged_alignment.txt

cd task7
python3 id2phone.py merged_alignment.txt ../data/lang/phones.txt > final_ali.txt
python3 getAudio.py $1 final_ali.txt ../corpus/lang/lexicon.txt ../corpus/data/wav/