#!/usr/bin/perl

use constant {
	DEBUG => 0,

	CHECKER_OK => 101,
	CHECKER_NOFLAG => 102,
	CHECKER_MUMBLE => 103,
	CHECKER_DOWN => 104,
	CHECKER_ERROR => 110
};

use constant {
	CONNECTION_ERROR => "Could not connect to service",
	INVALID_STRING => "Invalid string"
};

use Socket;

my $port = 18360;
my ($mode, $ip, $id, $flag) = @ARGV;
my %handlers = (
	'check' => \&check,
	'put' => \&put,
	'get' => \&get
);

socket S, PF_INET, SOCK_STREAM, getprotobyname 'tcp';
$cr = connect S, sockaddr_in $port, inet_aton $ip;
vec ($r = '', fileno (S), 1) = 1;
$handlers {$mode}->($id, $flag);

sub do_exit {
	my ($code, $msg, $log) = @_;
	
	if (DEBUG) { $msg = "\nOK" if CHECKER_OK == $code; }

	print $msg;
	print STDERR $log;
	close S;
	exit $code;
}

sub check {
	if ($cr) {
		do_exit (CHECKER_OK);
	}
	else {
		do_exit (CHECKER_DOWN, CONNECTION_ERROR);
	}
}

sub put {
	do_exit (CHECKER_DOWN, CONNECTION_ERROR) unless $cr;

	my $flag = $_[1];
	send S, $flag, 0;

	my $x = &geta;

	if ($flag eq $x) {
		do_exit (CHECKER_OK);
	}
	else {
		do_exit (CHECKER_MUMBLE, INVALID_STRING);
	}
}

sub get {
	do_exit (CHECKER_DOWN, CONNECTION_ERROR) unless $cr;
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

