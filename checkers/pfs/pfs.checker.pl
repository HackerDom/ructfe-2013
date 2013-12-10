#!/usr/bin/perl -wl

use feature ':5.10';
use HTTP::Tiny;

my ($SERVICE_OK, $FLAG_GET_ERROR, $SERVICE_CORRUPT, $SERVICE_FAIL, $INTERNAL_ERROR) = (101, 102, 103, 104, 110);
my %MODES = (check => \&check, get => \&get, put => \&put);

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

  my $ua = HTTP::Tiny->new(timeout => 10);
  my $response = $ua->get("http://$ip:3000/$id");
  return $SERVICE_FAIL unless $response->{success};
  return $FLAG_GET_ERROR unless $response->{status} == 200;
  return $response->{content} eq $flag ? $SERVICE_OK : $SERVICE_CORRUPT;
}

sub put {
  my ($id, $flag) = @_;

  my $ua = HTTP::Tiny->new(timeout => 10);
  my $response = $ua->put("http://$ip:3000/$id", {content => $flag});
  return $SERVICE_FAIL unless $response->{success};
  return $SERVICE_CORRUPT unless $response->{status} == 200;
  return $SERVICE_OK;
}
