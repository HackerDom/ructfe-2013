$TEAMS_COUNT = 2;
$SERVICES_COUNT = 5;
$EVENTS_COUNT = 100;
@wrd = ('Service OK', 'Service haven\'t flag', 'Service incorrect', 'Service down', 'Something else...');
%act = (
         0 => sub { @x = (1 + int rand $tc, 1 + int rand 2);
                    print F "at $time $x[0] $x[1]"; },
         1 => sub { @x = (1 + int rand $tc, 1 + int rand 2);
                    print F "de $time $x[0] $x[1]"; },
         2 => sub { @x = (1 + int rand $tc, 1 + int rand 2);
                    print F "ad $time $x[0] $x[1]"; },
         3 => sub { @x = (1 + int rand $tc, 1 + int rand 2);
                    print F "ta $time $x[0] $x[1]"; },
         4 => sub { @x = (1 + int rand $tc, 1 + int rand $tc, 1 + int rand $sc, 1 + int rand 2);
                    print F "f $time $x[0] $x[1] $x[2] $x[3]"; },
         5 => sub { @x = (1 + int rand $tc, 1 + int rand $sc, 1 + int rand 4, 1 + int rand (0+@wrd));
                    print F "s $time $x[0] $x[1] $x[2] $wrd[$x[3]]"; },
         6 => sub { @x = (1 + int rand $tc, 1 + int rand $tc, 1 + int rand $sc, 1 + int rand 2);
                    print F "f $time $x[0] $x[1] $x[2] $x[3]"; },
         7 => sub { @x = (1 + int rand $tc, 1 + int rand $sc, 1 + int rand 4, 1 + int rand (0+@wrd));
                    print F "s $time $x[0] $x[1] $x[2] $wrd[$x[3]]"; },
         8 => sub { @x = (1 + int rand $tc, 1 + int rand $tc, 1 + int rand $sc, 1 + int rand 2);
                    print F "f $time $x[0] $x[1] $x[2] $x[3]"; },
         9 => sub { @x = (1 + int rand $tc, 1 + int rand $sc, 1 + int rand 4, 1 + int rand (0+@wrd));
                    print F "s $time $x[0] $x[1] $x[2] $wrd[$x[3]]"; },
        10 => sub { @x = (1 + int rand $tc, 1 + int rand $tc, 1 + int rand $sc, 1 + int rand 2);
                    print F "f $time $x[0] $x[1] $x[2] $x[3]"; },
        11 => sub { @x = (1 + int rand $tc, 1 + int rand $sc, 1 + int rand 4, 1 + int rand (0+@wrd));
                    print F "s $time $x[0] $x[1] $x[2] $wrd[$x[3]]"; }
       );

&help, exit if lc $ARGV[0] eq '-h';

$tc = int (shift) || $TEAMS_COUNT;
$sc = int (shift) || $SERVICES_COUNT;
$ec = int (shift) || $EVENTS_COUNT;

$time = int rand 100_000;
open F, '>', 'monitor.dat';
$\ = $/;
for (1..$ec) {
  &{$act{int rand (0 + keys %act)}};
  $time += int rand 1_000;
}
close F;

sub help {
  print <<EOH;
Usage:
  mongen.pl <Teams-count> <Services-count> <Events-count>

Defaults:
  Teams-count    :: $TEAMS_COUNT
  Services-count :: $SERVICES_COUNT
  Events-count   :: $EVENTS_COUNT
EOH
}
