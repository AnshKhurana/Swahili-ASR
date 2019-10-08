# Compute WER according to quality

echo -n "(g) "
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_g_* | utils/best_wer.sh; done
echo -n "(l) "
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_l_* | utils/best_wer.sh; done
echo -n "(m) "
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_m_* | utils/best_wer.sh; done
echo -n "(n) "
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_n_* | utils/best_wer.sh; done
