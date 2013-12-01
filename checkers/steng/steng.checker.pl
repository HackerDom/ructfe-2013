#!/usr/bin/perl

use constant {
	DEBUG => 1,

	CHECKER_OK => 101,
	CHECKER_NOFLAG => 102,
	CHECKER_MUMBLE => 103,
	CHECKER_DOWN => 104,
	CHECKER_ERROR => 110
};

use constant {
	CONNECTION_ERROR => "Could not connect to service",
	CANNOT_GET_PICTURE => "Can't get picture",
	CANNOT_PUT_PICTURE => "Can't put picture",
	FLAG_NOT_FOUND => "Flag not found"
};

use Socket;
use SNG;

my $port = 18360;
my ($mode, $ip, $id, $flag) = @ARGV;
my %handlers = (
	'check' => \&check,
	'put' => \&put,
	'get' => \&get
);

socket S, PF_INET, SOCK_STREAM, getprotobyname 'tcp';
$cr = connect S, sockaddr_in $port, inet_aton $ip;
do_exit (CHECKER_DOWN, CONNECTION_ERROR) unless $cr;

vec ($r = '', fileno (S), 1) = 1;
$handlers {$mode}->($id, $flag);

sub do_exit {
	my ($code, $msg, $log) = @_;
	
	if (DEBUG) { $msg = "\nOK" if CHECKER_OK == $code; }

	print $msg;
	print STDERR $log;
	shutdown S, 2;
	exit $code;
}

sub check {
	send S, "list\n", 0;
	my @l = split /\s+/, &geta;
	my $p = int rand @l;

	send S, "getpic $p\n", 0;
	my $d = &geta;

	do_exit (CHECKER_MUMBLE, CANNOT_GET_PICTURE) if $d =~ /^ERROR/;
	do_exit (CHECKER_OK);
}

sub put {
	my $p = &SNG::generate_simple_sng;

	if (int rand 2) {
		send S, "putpic $flag\n$p\n", 0;
		my $d = &geta;

		do_exit (CHECKER_MUMBLE, CANNOT_PUT_PICTURE) if $d =~ /^ERROR/;

		print "1 $d";
	}
	else {
		my $pasw = join '', map { chr (ord ('a') + int rand 26) } 1 .. 8;
		send S, "putpic $flad $pasw\n$p\n", 0;
		my $d = &geta;

		do_exit (CHECKER_MUMBLE, CANNOT_PUT_PICTURE) if $d =~ /^ERROR/;

		print "2 $pasw:$d";
	}

	do_exit (CHECKER_OK);
}

sub get {
	my ($id, $flag) = @_;

	my @t = split /\s+/, $id, 2;
	if ($t[0] == 1) {
		my @x = split /;/, $t[1];
		send S, "getpic $x[0]\n", 0;
		my $d = &geta;

		do_exit (CHECKER_MUMBLE, CANNOT_GET_PICTURE) if $d =~ /^ERROR/;
		do_exit (CHECKER_NOFLAG, FLAG_NOT_FOUND) if SNG::unparse_flag ($d, $x[1]) ne $flag;
	}
	else {
		my @x = split /:/, $t[1];
		send S, "getpic $x[1] $x[0]\n", 0;
		my $d = &geta;

		do_exit (CHECKER_MUMBLE, CANNOT_GET_PICTURE) if $d =~ /^ERROR/;
		do_exit (CHECKER_NOFLAG, FLAG_NOT_FOUND) unless $d =~ qr/$flag/;
	}

	do_exit (CHECKER_OK);
}

sub geta {
	my $x = '';

	while (select '' . $r, undef, undef, 0.1) {
		recv S, ($_ = ''), 1024, 0;
		return $x unless length;
		$x .= $_;
	}

	$x;
}

