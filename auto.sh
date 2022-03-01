#!/bin/bash

### config ###
PYA0=/store2/scratch/w32zhong/pya0
#QREL=qrels.arqmath-2021-task1-official.txt
QREL=qrels.ntcir12-math-browsing.txt
###   END  ###

# ensure queryIDs in trec run files are only numbers!
sed -i runs/* -e 's/^A\.//g' -e 's/^NTCIR12-MathWiki-//g'

# fuse!
rm -rf fusion_output/ && python3 tools/sweep_polyfuse.py --depth 1000 runs/*

cp $PYA0/topics-and-qrels/$QREL .
sed -i $QREL -e 's/^A\.//g' -e 's/^NTCIR12-MathWiki-//g'

if [[ $QREL =~ "arqmath" ]]; then
    ### Official evaluation, but costly ###
    #$PYA0/eval-arqmath2-task1/preprocess.sh ./fusion_output/*
    #$PYA0/eval-arqmath2-task1/eval.sh $QREL
    #
    for run in $(ls fusion_output); do
        echo $run ====================
        trec_eval $QREL fusion_output/$run -J -m ndcg
        trec_eval $QREL fusion_output/$run -l2 -J -m map
        trec_eval $QREL fusion_output/$run -l2 -J -m P.10
        trec_eval $QREL fusion_output/$run -l2 -m bpref
    done
else
    for run in $(ls fusion_output); do
        echo $run ====================
        trec_eval $QREL fusion_output/$run -l3 -m bpref
        trec_eval $QREL fusion_output/$run -l1 -m bpref
    done
fi
