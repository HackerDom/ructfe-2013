#!/usr/bin/perl -wl

use feature ':5.10';
use HTTP::Tiny;

my ($SERVICE_OK, $SERVICE_MUMBLE, $SERVICE_CORRUPT, $SERVICE_FAIL, $INTERNAL_ERROR) = (101, 102, 103, 104, 110);
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
  my $ua = HTTP::Tiny->new(timeout => 5);
  my $response = $ua->get("http://$ip:4369/list");
  return $SERVICE_FAIL unless $response->{success};
  return $SERVICE_MUMBLE unless $response->{status} == 200;
  return $SERVICE_OK;
}

sub get {
  my ($complex_id, $flag) = @_;
  
  my ($id, $enc) = split /\s+/, $complex_id;

  my $ua = HTTP::Tiny->new(timeout => 5);
  my $response = $ua->get("http://$ip:4369/get?id=$id&enc=$enc");
  return $SERVICE_FAIL unless $response->{success};
  return $SERVICE_MUMBLE unless $response->{status} == 200;
  return $response->{content} eq $flag ? $SERVICE_OK : $SERVICE_CORRUPT;
}

sub put {
  my ($id, $flag) = @_;

  my $ua = HTTP::Tiny->new(timeout => 5);
  my $response = $ua->get("http://$ip:4369/put?mes=$flag");
  $new_id = $response->{content};

  @tokens = split /\s/, $new_id;
  exit $SERVICE_CORRUPT if $#tokens != 1;
  return $SERVICE_FAIL unless $response->{success};
  return $SERVICE_MUMBLE unless $response->{status} == 200;

  print STDOUT $new_id;
  return $SERVICE_OK;
}
