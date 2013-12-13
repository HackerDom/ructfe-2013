#!/bin/bash
if [ -z "$1" ]
then
	echo "Give checkers.cfg as argument"
	exit 1
fi

java -classpath .:external/postgresql-8.4-701.jdbc4.jar:external/junit-4.6.jar:external/log4j-1.2.15.jar ructf.daemon.Main daemon.cfg $1
