#!/bin/bash
while [ 1 ]
do
	./json-writer-domi.pl f1.conf f2.conf > /var/www/scoreboard/data/attack.json.new
	mv /var/www/scoreboard/data/attack.json.new /var/www/scoreboard/data/attack.json
	echo Done - `date`, sleeping...
	sleep 30
done

