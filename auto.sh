#!/bin/bash
# ensure queryIDs in trec run files are only numbers!
rm -rf fusion_output/ && tools/sweep_polyfuse.py --depth 1000 runs/*
