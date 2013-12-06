#!/usr/bin/perl -wl

use feature ':5.10';
use IO:Socket::INET;

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
  print $sock "list";
  my $resp = <$sock>;
  if($resp !~ /\.list: value/) {
    return $SERVICE_OK;
  }
  else {
    return $SERVICE_FAIL;
  }
}

sub get {
  my ($id, $flag) = @_;

  my $sock = IO::Socket::INET->new("$ip:$port");

  print $sock "fget$id";
  return $SERVICE_FAIL unless $sock;

  my $resp = <$sock>;

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
