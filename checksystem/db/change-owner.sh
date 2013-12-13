#!/bin/bash

# Change owner of all tables, sequences, views for a database

if [ -z "$2" ]
then
	echo Usage: change-owner.sh dbname dbuser
	exit 1
fi

DBNAME=$1
DBUSER=$2

echo " *** change-owner.sh: owner all items of $DBNAME -> $DBUSER ... "

# 1. Tables

for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" $DBNAME` 
do
	psql -c "alter table $tbl owner to $DBUSER" $DBNAME
done

# 2. Sequences

for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" $DBNAME`
do
	psql -c "alter table $tbl owner to $DBUSER" $DBNAME
done

# 3. Views

for tbl in `psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" $DBNAME`
do
	psql -c "alter table $tbl owner to $DBUSER" $DBNAME
done

