#!/bin/bash

echo " *** Stopping CCP (Checksystem Control Panel) ..."

for pid in `pgrep -f 'perl bin/app.pl'`
do
	echo -n "Killing pid $pid ... "
	kill $pid
	echo done.
done

echo " *** Checking PIDs: `pgrep -f 'perl bin/app.pl'`"
