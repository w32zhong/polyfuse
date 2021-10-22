#!/bin/bash

# ensure queryIDs in trec run files are only numbers!
rm -rf fusion_output/ && tools/sweep_polyfuse.py --depth 1000 runs/*

#QRELS=qrels.ntcir12-math-browsing-concrete.txt
#for run in $(ls fusion_output); do
#	echo $run
#	trec_eval $QRELS -m bpref -l1 fusion_output/$run
#	trec_eval $QRELS -m bpref -l3 fusion_output/$run
#done

QRELS=qrels.arqmath-2021-task1.txt
for run in $(ls fusion_output); do
	echo $run
	trec_eval $QRELS fusion_output/$run -J -m ndcg
	trec_eval $QRELS fusion_output/$run -l2 -J -m map
	trec_eval $QRELS fusion_output/$run -l2 -J -m P.10
	trec_eval $QRELS fusion_output/$run -l2 -m bpref
done
