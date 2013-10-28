#!/usr/bin/perl

use strict;
use DBI;
use CGI qw/:standard/;
++$|;

# ------------- Config ---------------

my $dbhost = '127.0.0.1';
my $dbname = 'r2k9';
my $dbuser = 'r2k9';
my $dbpass = '87ertfguy32r';

# ------------------------------------



my $dbh = DBI->connect( "DBI:Pg:dbname=$dbname;host=$dbhost", $dbuser, $dbpass, {RaiseError=>0, AutoCommit=>1} )
	or die "Can't connect to database\n";

my $mode = param('mode');
if ($mode eq 'score')
{
	print header(-type=>'text/xml').execute( 'SELECT * FROM xmlscoreboard' );
}
elsif ($mode eq 'flags')
{
	print header(-type=>'text/xml').execute( 'SELECT * FROM xmlflags' );
}
else
{
	print header();
	print a({href=>"scoreboard.pl?mode=score"},"Scoreboard"), br;
	print a({href=>"scoreboard.pl?mode=flags"},"Flags"), br;
}

$dbh->disconnect;
exit 0;

# -----------------------------------------

sub execute
{
	my $query = shift;
	my $sth = $dbh->prepare($query)		or die $dbh->errstr;
	$sth->execute				or die $sth->errstr;
	return $sth->fetchrow_arrayref->[0];
}

