#!/usr/bin/perl

use DBI;
use JSON;
use strict;

my $F_SERV     = 'services.json';
my $F_TEAMS    = 'teams.json';
my $F_STATUS   = 'status.json';
my $F_SCORE    = 'score.json';
my $F_INFO     = 'info.txt';

my %STATUS_TXT = (
	101 => 'up', 
	102 => 'corrupt',
	103 => 'mumble',
	104 => 'down'
);

my $dbh;
my %conf;
my %teams;
my %serv;
my %status;
my $round;
my @score;

sub db_connect {
	my %conf = @_;
	my $connstr = sprintf "DBI:Pg:dbname=%s;host=%s;port=%d", $conf{db_name}, $conf{db_host}, $conf{db_port};
	return DBI->connect($connstr, $conf{db_user}, $conf{db_pass}, {'RaiseError' => 1});
}

sub db_readhash {
        my ($table,$key,$value)=@_;
        my %result;
        my $sth = $dbh->prepare("SELECT $key, $value FROM $table");
        $sth->execute();
        while(my $ref = $sth->fetchrow_hashref()) {
                $result{ $ref->{$key} } = $ref->{$value};
        }
        return %result;
}

sub db_round {
        my $sth = $dbh->prepare("SELECT max(n) FROM rounds");
	$sth->execute();
	my $ref = $sth->fetchrow_arrayref();
	my $round = $ref->[0];

	return $round;
}

sub read_conf {
	my $fname = shift;
	my %conf = ();
	open F, $fname or die "Error: cannot open config: $fname\n";
	while (<F>) {
		chomp;
		my ($key,$val) = split/:/;
		$val =~ s/^ +//;
		$val =~ s/ +$//;
		$conf{$key}=$val;
	}
	close F;
	return %conf;
}

sub write_json {
	my ($fname, %data) = @_;
	open F, "> $fname.new" or die "Error: cannot write $fname.new\n";
	print F to_json(\%data, {pretty => 1});
	close F;
	rename "$fname.new", $fname;
	print "  write_json -> $fname - done\n";
}

sub write_json_arr {
	my ($fname, @data) = @_;
	open F, "> $fname.new" or die "Error: cannot write $fname.new\n";
	print F to_json(\@data, {pretty => 1});
	close F;
	rename "$fname.new", $fname;
	print "  write_json_arr -> $fname - done\n";
}

sub write_plain {
	my ($fname, $data) = @_;
	open F, "> $fname.new" or die "Error: cannot write $fname.new\n";
	print F $data;
	close F;
	rename "$fname.new", $fname;
	print "  write_plain -> $fname - done\n";
}

sub read_status {
	my %status;
        my $sth = $dbh->prepare("SELECT team_id, service_id, status, fail_comment FROM service_status");
        $sth->execute();
        while(my $ref = $sth->fetchrow_hashref()) {
		$status{$ref->{team_id}, $ref->{service_id}} = $STATUS_TXT{$ref->{status}};
        }
	return %status;
}

sub tojson {
	my %status = @_;
	my %ret;
	for my $tid (keys %teams) {
		$ret{$tid} = {};
		for my $sid (keys %serv) {
			$ret{$tid}->{$sid} = $status{$tid,$sid};
		}
	}
	return %ret;
}

sub db_score {
	my @ret;
	my $round = shift;
        my $sth = $dbh->prepare("SELECT team_id, sum(privacy) as privacy, sum(availability) as availability, sum(attack) as attack FROM rounds_cache GROUP BY team_id");
	$sth->execute();
	my $MAX_DEF = 1;
	my $MAX_ATT = 1;
        while(my $ref = $sth->fetchrow_hashref()) {
		my $h = {};
		$h->{team} = $ref->{team_id};
		$h->{def}  = $ref->{privacy} + $ref->{availability};
		$h->{att}  = $ref->{attack};
		$MAX_DEF=$h->{def} if $h->{def}>$MAX_DEF;
		$MAX_ATT=$h->{att} if $h->{att}>$MAX_ATT;
#		printf "%d %d\n", $h->{def}, $h->{att};
		push @ret, $h;
	}
	my %rate;
	my $MAX_RATE = 1;
	for (@ret) {
		my $P_DEF = 100*$_->{def}/$MAX_DEF;
		my $P_ATT = 100*$_->{att}/$MAX_ATT;
		$_->{def_p} = sprintf "%.2f", $P_DEF;
		$_->{att_p} = sprintf "%.2f", $P_DEF; 
		$rate{$_->{team}} = $P_DEF+$P_ATT;
		$MAX_RATE=$rate{$_->{team}} if $rate{$_->{team}}>$MAX_RATE;
	}
	for (@ret) {
		$_->{rat} = sprintf "%.2f", 100*$rate{$_->{team}}/$MAX_RATE;
	}
	return @ret;
}

my $conf = shift or die "Usage: json-writer.pl db-config\n";

printf "json-writer: staring: %s\n", scalar localtime;

%conf = read_conf $conf;
$dbh = db_connect %conf;

%teams  = db_readhash qw/teams id name/;
%serv   = db_readhash qw/services id name/;
%status = read_status();
$round  = db_round();
@score  = db_score($round-1);

my %sthash = tojson(%status);

write_json      "$conf{outdir}/$F_TEAMS",   %teams;
write_json      "$conf{outdir}/$F_SERV",    %serv;
write_json      "$conf{outdir}/$F_STATUS",  %sthash;
write_plain     "$conf{outdir}/$F_INFO",    "Round: " + $round;
write_json_arr  "$conf{outdir}/$F_SCORE",   @score;

$dbh->disconnect;

printf "json-writer: finished: %s\n", scalar localtime;

