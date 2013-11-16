#!/usr/bin/perl -wl

use feature ':5.10';
use Net::TFTP;

my ($SERVICE_OK, $FLAG_GET_ERROR, $SERVICE_CORRUPT, $SERVICE_FAIL, $INTERNAL_ERROR) = (101, 102, 103, 104, 110);
my %MODES = (check => \&check, get => \&get, put => \&put);
my %OPTS  = (Timeout => 3, Retries => 1);

my ($mode, $ip) = splice @ARGV, 0, 2;

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
  return $SERVICE_OK;
}

sub get {
  my ($id, $flag) = @_;

  my $tftp = Net::TFTP->new($ip, %OPTS);
  my $fh = $tftp->get($id);
  sysread $fh, my $data, length $flag;
  return $FLAG_GET_ERROR unless defined $data;

  return $data eq $flag ? $SERVICE_OK : $FLAG_GET_ERROR;
}

sub put {
  my ($id, $flag) = @_;

  my $tftp = Net::TFTP->new($ip, %OPTS);
  my $fh = $tftp->put($id);
  my $len = syswrite $fh, $flag, length $flag;
  close $fh;
  return $SERVICE_FAIL unless $len == length $flag;

  return $SERVICE_OK;
}
