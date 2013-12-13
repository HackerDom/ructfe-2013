#!/bin/bash
DST=../checksystem/project/checkers


for dir in aploader contacts cryptoboard hammer nsaless pfs steng taxi web
do
	for file in $dir/*
	do
		if [ -f "$file" ]
		then
			cp -v $file $DST
		fi
	done
done

