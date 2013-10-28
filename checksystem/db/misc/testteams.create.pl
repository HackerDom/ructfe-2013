#!/usr/bin/perl

printf "INSERT INTO teams VALUES ( %d, 'Team %d', '10.%d.0.0/16', '10.%d.0.3', true );$/", $_,$_,$_,$_ for 1..8;

