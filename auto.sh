#!/bin/bash

### config ###
PYA0=/store2/scratch/w32zhong/math-dense-retrievers.emnlp/code/pya0
QREL=qrels.arqmath-2021-task1-official.txt
#QREL=qrels.ntcir12-math-browsing.txt
###   END  ###

# ensure queryIDs in trec run files are only numbers!
sed -i runs/* -e 's/^A\.//g' -e 's/^NTCIR12-MathWiki-//g'

# fuse!
rm -rf fusion_output/ && python3 tools/sweep_polyfuse.py --depth 1000 runs/*

rm -f ./qrels.*
cp $PYA0/topics-and-qrels/$QREL .
sed -i $QREL -e 's/^A\.//g' -e 's/^NTCIR12-MathWiki-//g'

if [[ $QREL =~ "arqmath" ]]; then
    ##### Quick and unofficial evaluation ###
    #for run in $(ls fusion_output); do
    #    ndcg=$(trec_eval $QREL fusion_output/$run -J -m ndcg | awk '{print $3}')
    #    map=$(trec_eval $QREL fusion_output/$run -l2 -J -m map | awk '{print $3}')
    #    p10=$(trec_eval $QREL fusion_output/$run -l2 -J -m P.10 | awk '{print $3}')
    #    bpref=$(trec_eval $QREL fusion_output/$run -l2 -m bpref | awk '{print $3}')
    #    echo $run $ndcg $map $p10 $bpref
    #done

    #### Official evaluation, but costly ###
    $PYA0/eval-arqmath2-task1/preprocess.sh cleanup
    $PYA0/eval-arqmath2-task1/preprocess.sh ./fusion_output/*
    $PYA0/eval-arqmath2-task1/eval.sh --qrels=$QREL
else
    for run in $(ls fusion_output); do
        bpref_full=$(trec_eval $QREL fusion_output/$run -l3 -m bpref | awk '{print $3}')
        bpref_part=$(trec_eval $QREL fusion_output/$run -l1 -m bpref | awk '{print $3}')
        echo $run $bpref_full $bpref_part
    done
fi
