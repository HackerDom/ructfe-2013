#!/usr/bin/perl -w

use feature ':5.10';
use IO::Socket::INET;

my ($SERVICE_OK, $FLAG_GET_ERROR, $SERVICE_CORRUPT, $SERVICE_FAIL, $INTERNAL_ERROR) = (101, 102, 103, 104, 110);
my %MODES = (check => \&check, get => \&get, put => \&put);

my ($mode, $ip) = splice @ARGV, 0, 2;
my $port = 4242;

unless (defined $mode and defined $ip) {
  warn "Invalid input. Empty mode or ip address.";
  exit $INTERNAL_ERROR;
}

unless ($mode ~~ %MODES) {
  warn "Invalid mode.";
  exit $INTERNAL_ERROR;
}

exit $MODES{$mode}->(@ARGV);

sub check {
  my $sock = IO::Socket::INET->new("$ip:$port");
  return $SERVICE_FAIL unless $sock;
  print $sock "list";
  shutdown $sock, 1;
  my $resp = '';
  while(my $line = <$sock>) {
      print "$line\n";
	  $resp .= $line;
  }
  if($resp !~ /\.list: value/) {
    return $SERVICE_OK;
  }
  else {
    return $SERVICE_FAIL;
  }
}

sub get {
  my ($id, $flag) = @_;

  $sock = IO::Socket::INET->new("$ip:$port");
  return $SERVICE_FAIL unless $sock;
  print $sock "list";
  shutdown $sock, 1;
  my $id_tl = substr $id, length($id) - 8, 8;
  my $found = 0;

  while(my $line = <$sock>) {
	  chomp $line;
	  if((substr $line, length($line) - 8, 8) eq $id_tl) {
		  $found = 1;
		  last;
	  }
  }

  if(! $found) {
	  return $FLAG_GET_ERROR;
  }

  my $sock = IO::Socket::INET->new("$ip:$port");
  return $SERVICE_FAIL unless $sock;

  print $sock "fget$id";
  return $SERVICE_FAIL unless $sock;
  shutdown $sock, 1;

  my $resp = <$sock>;
  chomp $resp;

  return $resp eq $flag ? $SERVICE_OK : $FLAG_GET_ERROR;
}

sub put {
  my ($id, $flag) = @_;

  $id = newid();
  print "$id\n";

  my $sock = IO::Socket::INET->new("$ip:$port");
  return $SERVICE_FAIL unless $sock;

  print $sock "fput$id$flag";

  return $SERVICE_OK;
}

sub newid {
	my @chars = ("A".."Z", "a".."z", "0".."9");
	my $string;
	$string .= $chars[rand @chars] for 1..16;
	return $string;
}
