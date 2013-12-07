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
	CANNOT_GET_PICTURE => "Can't get picture",
	CANNOT_PUT_PICTURE => "Can't put picture",
	FLAG_NOT_FOUND => "Flag not found"
};
my @perc = qw/45 35 20/;

use Socket;
use SNG;

my $port = 18360;
my ($mode, $ip, $id, $flag) = @ARGV;
my %handlers = (
	'check' => \&check,
	'put' => \&put,
	'get' => \&get
);

socket $S, PF_INET, SOCK_STREAM, getprotobyname 'tcp';
$cr = connect $S, sockaddr_in $port, inet_aton $ip;
do_exit (CHECKER_DOWN, CONNECTION_ERROR) unless $cr;

vec ($v = '', fileno ($S), 1) = 1;
$| = 1;

$handlers {$mode}->($id, $flag);

sub do_exit {
	my ($code, $msg, $log) = @_;
	
	if (DEBUG) { $msg = "\nOK" if CHECKER_OK == $code; }

	print $msg;
	print STDERR $log;
	shutdown $S, 2;
	exit $code;
}

sub check {
	send $S, "list\n", 0;

	my @list = split /\s+/, &get_all;
	do_exit (CHECKER_OK) unless @list;

	my $pic = $list[int rand @list];

	send $S, "getpic $pic\n", 0;
	my $data = &get_all;

	do_exit (CHECKER_MUMBLE, CANNOT_GET_PICTURE) if $data =~ /^ERROR/ && !($data =~ /^ERROR\(PASSWORD\)/);
	do_exit (CHECKER_OK);
}

sub passw_gen {
	my @p = map { chr (ord ('a') + int rand 26) } 1 .. (80 + int rand 20);
	my $p = join '', @p;

	my $k = @p / 5;
	splice @p, int rand @p, 1 for 1 .. $k;
	my $P = join '', @p;

	($p, $P);
}

sub put {
	my $type = int rand 100;
	my $pic = ($type < $perc[0] + $perc[1]) ? &SNG::generate_simple_sng : &SNG::generate_palette_sng;

	if ($type < $perc[0] || $type >= $perc[0] + $perc[1]) {
		send $S, "putpic $flag\n$pic\n", 0;
		my $data = &get_all;

		do_exit (CHECKER_MUMBLE, CANNOT_PUT_PICTURE) if $data =~ /^ERROR/;

		print "1 $data";
	}
	else {
		my ($psw1, $psw2) = &passw_gen;
		send $S, "putpic $flag $psw1\n$pic\n", 0;
		my $data = &get_all;

		do_exit (CHECKER_MUMBLE, CANNOT_PUT_PICTURE) if $data =~ /^ERROR/;

		print "2 $psw2:$data";
	}

	do_exit (CHECKER_OK);
}

sub expand_psw {
	my @p = (shift);
	my $l = length $p[0];
	my $n = int rand 8;

	push @p, (join '', map { chr (ord ('a') + int rand 26) } 1 .. $l) for 1 .. $n;
	"@p";
}

sub get {
	my ($id, $flag) = @_;

	my @type = split /\s+/, $id, 2;
	if ($type[0] == 1) {
		my @x = split /;/, $type[1];

		send $S, "getpic $x[0]\n", 0;
		my $data = &get_all;

		do_exit (CHECKER_MUMBLE, CANNOT_GET_PICTURE) if $data =~ /^ERROR/;
		do_exit (CHECKER_NOFLAG, FLAG_NOT_FOUND) if SNG::unparse_flag ($data, $x[1]) ne $flag;
	}
	else {
		my @x = split /:/, $type[1];

		$x[0] = expand_psw ($x[0]);
		send $S, "getpic $x[1] $x[0]\n", 0;
		my $data = &get_all;

		do_exit (CHECKER_MUMBLE, CANNOT_GET_PICTURE) if $data =~ /^ERROR/;
		do_exit (CHECKER_NOFLAG, FLAG_NOT_FOUND) unless $data =~ qr/$flag/;
	}

	do_exit (CHECKER_OK);
}

sub get_all {
	my ($x, $t) = '';
 
	while (select '' . $v, undef, undef, 0.2) {
		recv $S, ($t = ''), 1024, 0;
		return $x unless length $t;
		$x .= $t;
	}

	$x;
}

