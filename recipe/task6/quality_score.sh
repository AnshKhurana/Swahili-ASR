#!/bin/bash
# Copyright 2012  Johns Hopkins University (Author: Daniel Povey)
# Apache 2.0

[ -f ./path.sh ] && . ./path.sh

# begin configuration section.
cmd=run.pl
stage=0
decode_mbr=true
word_ins_penalty=0.0
min_lmwt=7
max_lmwt=17
#end configuration section.

[ -f ./path.sh ] && . ./path.sh
. parse_options.sh || exit 1;

if [ $# -ne 3 ]; then
  echo "Usage: local/score.sh [--cmd (run.pl|queue.pl...)] <data-dir> <lang-dir|graph-dir> <decode-dir>"
  echo " Options:"
  echo "    --cmd (run.pl|queue.pl...)      # specify how to run the sub-processes."
  echo "    --stage (0|1|2)                 # start scoring script from part-way through."
  echo "    --decode_mbr (true/false)       # maximum bayes risk decoding (confusion network)."
  echo "    --min_lmwt <int>                # minumum LM-weight for lattice rescoring " # A parameter for maintaining different weights of the language model
  echo "    --max_lmwt <int>                # maximum LM-weight for lattice rescoring "
  exit 1;
fi

data=$1
lang_or_graph=$2
dir=$3

symtab=$lang_or_graph/words.txt

for f in $symtab $dir/lat.1.gz $data/text; do
  [ ! -f $f ] && echo "score.sh: no such file $f" && exit 1;
done

mkdir -p $dir/scoring/log

cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g' > $dir/scoring/test_filt.txt
cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g'| sed -n '/^[^[:space:]]*g[[:space:]]/p'  > $dir/scoring/test_filt_g.txt
cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g'| sed -n '/^[^[:space:]]*l[[:space:]]/p'> $dir/scoring/test_filt_l.txt
cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g'| sed -n '/^[^[:space:]]*m[[:space:]]/p' > $dir/scoring/test_filt_m.txt
cat $data/text | sed 's:<NOISE>::g' | sed 's:<SPOKEN_NOISE>::g'| sed -n '/^[^[:space:]]*n[[:space:]]/p' > $dir/scoring/test_filt_n.txt

# Evaluate Default step 1
$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/best_path.LMWT.log \
  lattice-scale --inv-acoustic-scale=LMWT "ark:gunzip -c $dir/lat.*.gz|" ark:- \| \
  lattice-add-penalty --word-ins-penalty=$word_ins_penalty ark:- ark:- \| \
  lattice-best-path --word-symbol-table=$symtab \
    ark:- ark,t:$dir/scoring/LMWT.tra || exit 1;
# run loop over quality segments - Step

#g
# Note: the double level of quoting for the sed command
$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/score.LMWT.log \
   cat $dir/scoring/LMWT.tra \| \
    utils/int2sym.pl -f 2- $symtab \| sed 's:\<UNK\>::g' \| \
    compute-wer --text --mode=present \
     ark:$dir/scoring/test_filt_g.txt  ark,p:- ">&" $dir/werg_LMWT || exit 1;

# l

# Note: the double level of quoting for the sed command
$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/score.LMWT.log \
   cat $dir/scoring/LMWT.tra \| \
    utils/int2sym.pl -f 2- $symtab \| sed 's:\<UNK\>::g' \| \
    compute-wer --text --mode=present \
     ark:$dir/scoring/test_filt_l.txt  ark,p:- ">&" $dir/werl_LMWT || exit 1;


# m

# Note: the double level of quoting for the sed command
$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/score.LMWT.log \
   cat $dir/scoring/LMWT.tra \| \
    utils/int2sym.pl -f 2- $symtab \| sed 's:\<UNK\>::g' \| \
    compute-wer --text --mode=present \
     ark:$dir/scoring/test_filt_m.txt  ark,p:- ">&" $dir/werm_LMWT || exit 1;

# n

# Note: the double level of quoting for the sed command
$cmd LMWT=$min_lmwt:$max_lmwt $dir/scoring/log/score.LMWT.log \
   cat $dir/scoring/LMWT.tra \| \
    utils/int2sym.pl -f 2- $symtab \| sed 's:\<UNK\>::g' \| \
    compute-wer --text --mode=present \
     ark:$dir/scoring/test_filt_n.txt  ark,p:- ">&" $dir/wern_LMWT || exit 1;



# for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done

# Printing score after decoding on different quality data
echo -n "(g) "
for x in $dir; do [ -d $x ] && grep WER $x/werg_* | utils/best_wer.sh; done
echo -n "(l) "
for x in $dir; do [ -d $x ] && grep WER $x/werl_* | utils/best_wer.sh; done
echo -n "(m) "
for x in $dir; do [ -d $x ] && grep WER $x/werm_* | utils/best_wer.sh; done
echo -n "(n) "
for x in $dir; do [ -d $x ] && grep WER $x/wern_* | utils/best_wer.sh; done
# Computing the best WERs
# g,l,m,n
exit 0;
