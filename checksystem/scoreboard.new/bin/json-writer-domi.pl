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
my @torder;
my %rate;

my %GR = ();
while (<DATA>) {
	chomp;
	$GR{$_}=1;
}
close DATA;

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

sub write_json_raw {
	my ($fname, @torder) = @_;
	open F, "> $fname.new" or die "Error: cannot write $fname.new\n";
#	print F to_json(\%data, {pretty => 1});
	print F "{";
	print F join ",\n", map { $teams{$_}=~s/"/\\"/g; sprintf '"%s" : "%s"', $_, $teams{$_}  } @torder;
	print F "}";
	close F;
	rename "$fname.new", $fname;
	print "  write_json -> $fname - done\n";

}

@ARGV == 2 or die;

my ($conf1, $conf2) = @ARGV;

#printf "json-writer: staring: %s\n", scalar localtime;

my %conf1 = read_conf $conf1;
my %conf2 = read_conf $conf2;
my $dbh1 = db_connect %conf1;
my $dbh2 = db_connect %conf2;

my ($at1, $as1, $srv1, $min1, $max1) = do_job($dbh1);
my ($at2, $as2, $srv2, $min2, $max2) = do_job($dbh2);

my @at = (@$at1, @$at2);
my @as = (@$as1, @$as2);
my $min = $min1<$min2 ? $min1 : $min2;
my $max = $max1>$max2 ? $max1 : $max2;

my %domi = (
	services => $srv1,
	attacks  => \@as,
	maxRound => $max,
	minRound => $min,
	teams    => \@at
);
print to_json(\%domi, {pretty=>1});
exit 0;

#my %domi = (
#	services => \@serv2,
#	attacks  => \@attacks,
#	maxRound => $maxr,
#	minRound => $minr,
#	teams    => \@teams2
#);
#print to_json(\%domi, {pretty=>1});


$dbh1->disconnect;
$dbh2->disconnect;
printf "json-writer: finished: %s\n", scalar localtime;
exit 0;

##############

sub do_job {

	$dbh = shift;

	%teams  = db_readhash qw/teams id name/;
	%serv   = db_readhash qw/services id name/;

	my @attacks;
	my $sth = $dbh->prepare("select extract(hour from time)*3600 + extract(minute from time)*60 + extract(second from time) as ts, team_id, victim_team_id, victim_service_id from stolen_flags where time > (NOW() - interval '5 minutes')");
	$sth->execute();
	my $maxr = -1;
	my $minr = 999999999;
	while(my $ref = $sth->fetchrow_hashref()) {
		push @attacks, { 
			from => $ref->{team_id},
			to => $ref->{victim_team_id},
			round => $ref->{ts},
			service => $ref->{victim_service_id}
		};
		$maxr=$ref->{ts} if $ref->{ts}>$maxr;
		$minr=$ref->{ts} if $ref->{ts}<$minr;
	}

	db_score();

	my @teams2;
	for (keys %teams) {
	push @teams2, {
		score => $rate{$_},
		group => exists $GR{$_} ? "0":"1",
		name => $teams{$_},
		id => $_
	};
	}
	my @serv2 = map { { id=>$_,name=>$serv{$_} } } keys %serv;

	return (\@teams2, \@attacks, \@serv2, $minr, $maxr);
}
#%status = read_status();
#@score  = db_score($round-1);

#my %sthash = tojson(%status);

#write_json      "$conf{outdir}/$F_TEAMS",   %teams;
#write_json      "$conf{outdir}/$F_SERV",    %serv;
#write_json      "$conf{outdir}/$F_STATUS",  %sthash;
#write_plain     "$conf{outdir}/$F_INFO",    "Round: " + $round;
#write_json_arr  "$conf{outdir}/$F_SCORE",   @score;

#@torder = sort { $rate{$b} <=> $rate{$a} } keys %teams;
#write_json_arr  "$conf{outdir}/order.json", @torder;


__DATA__
27
16
35
10
6
138
12
87
60
26
21
15
48
64
9
50
63
51
73
25
18
38
20
28
8
88
53
19
71
1

