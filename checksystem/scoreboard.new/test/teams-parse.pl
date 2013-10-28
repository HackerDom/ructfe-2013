#!/usr/bin/perl

while (<>) {
	/team id='(\d+)' name='(.*?)'/ or next;
	print "$1;$2\n";
}

