#!/bin/bash

if [[ -z $3 ]]; then
	echo usage: run.sh USER DATABASE SQLSCRIPT
	exit 1
fi

psql --quiet -U $1 -d $2 -f $3 
echo run.sh: finished.
