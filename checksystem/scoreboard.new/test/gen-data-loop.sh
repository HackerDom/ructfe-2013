#!/bin/bash
while [ 1 ]; do 
	./gen-data.pl 999 data/3
	./gen-data.pl 50 data/2
	sleep 10
done
