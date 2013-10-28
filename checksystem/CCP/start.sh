#!/bin/sh

echo "Starting CCP (Checksystem Control Panel) ..."

screen -dmS CCP perl bin/app.pl
screen -ls | grep CCP

