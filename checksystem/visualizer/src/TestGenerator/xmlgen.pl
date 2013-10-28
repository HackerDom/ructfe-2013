$TEAMS_COUNT = 2;
$SERVICES_COUNT = 5;

&help, exit if lc $ARGV[0] eq '-h';

$tc = int (shift) || $TEAMS_COUNT;
$sc = int (shift) || $SERVICES_COUNT;

open F, '>', 'teams.xml';
  print F <<HEAD;
<?xml version="1.0" encoding="utf-8"?>

<teams>
HEAD
  print F "  <team id=\"$_\" name=\"Team $_\" />\n" for 1..$tc;
  print F "</teams>";
close F;

open F, '>', 'services.xml';
  print F <<HEAD;
<?xml version="1.0" encoding="utf-8"?>

<services>
HEAD
  print F "  <service id=\"$_\" name=\"Service $_\" />\n" for 1..$sc;
  print F "</services>";
close F;

sub help {
  print <<EOH;
Usage:
  xmlgen.pl <Teams-count> <Services-count>

Defaults:
  Teams-count    :: $TEAMS_COUNT
  Services-count :: $SERVICES_COUNT
EOH
}
