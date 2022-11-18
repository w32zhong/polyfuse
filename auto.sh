#!/bin/bash

### config ###
PYA0=/store2/scratch/w32zhong/math-dense-retrievers.verynew/code/pya0
QREL=qrels.arqmath-2022-task1-or-task3-origin.txt
TASK=arqmath3
###   END  ###

# ensure queryIDs in trec run files are only numbers!
sed -i runs/* -e 's/^A\.//g' -e 's/^NTCIR12-MathWiki-//g'

# fuse!
rm -rf fusion_output/ && python3 tools/sweep_polyfuse.py --depth 1000 runs/*

rm -f ./qrels.*
cp $PYA0/topics-and-qrels/$QREL .
sed -i $QREL -e 's/^A\.//g' -e 's/^NTCIR12-MathWiki-//g'

if [[ $TASK =~ "arqmath2" ]]; then
    #### Official evaluation, but costly ###
    $PYA0/eval-arqmath2-task1/preprocess.sh cleanup
    $PYA0/eval-arqmath2-task1/preprocess.sh ./fusion_output/*
    $PYA0/eval-arqmath2-task1/eval.sh --qrels=$QREL --nojudge
elif [[ $TASK =~ "arqmath3" ]]; then
    #### Official evaluation, but costly ###
    $PYA0/eval-arqmath3/task1/preprocess.sh cleanup
    $PYA0/eval-arqmath3/task1/preprocess.sh ./fusion_output/*
    $PYA0/eval-arqmath3/task1/eval.sh --qrels=$QREL --nojudge
else
    for run in $(ls fusion_output); do
        bpref_full=$(trec_eval $QREL fusion_output/$run -l3 -m bpref | awk '{print $3}')
        bpref_part=$(trec_eval $QREL fusion_output/$run -l1 -m bpref | awk '{print $3}')
        echo $run $bpref_full $bpref_part
    done
fi
