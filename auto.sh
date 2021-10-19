#!/bin/bash

# ensure queryIDs in trec run files are only numbers!
rm -rf fusion_output/ && tools/sweep_polyfuse.py --depth 1000 runs/*

QRELS=qrels.ntcir12-math-browsing-concrete.txt
for run in $(ls fusion_output); do
	echo $run
	trec_eval $QRELS -m bpref -l1 fusion_output/$run
	trec_eval $QRELS -m bpref -l3 fusion_output/$run
done
