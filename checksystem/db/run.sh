#!/bin/bash

if [[ -z $1 ]]; then
	echo usage: run.sh script.sql [db-config]
	exit 1
fi

if [[ -z $2 ]]; then
	DB_CONFIG=db.config
else
	DB_CONFIG=$2
fi

echo run.sh: run with config: $DB_CONFIG
. $DB_CONFIG
psql --quiet -h $DB_HOST -U $DB_USER -d $DB_BASE -f $1
echo run.sh: finished.

