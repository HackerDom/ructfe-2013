$MONITOR_FILE = 'monitor.dat';

&help, exit if lc $ARGV[0] eq '-h';

my $f = shift || $MONITOR_FILE;

open F, '<', $f;
  while (<F>) {
    ++$n;
    print "\r$n ..." unless $n % 1000;
    if (/^s\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/) {
      $s[$2][$3] = $4;
      push @a, $_;
    }
    elsif (/^f\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/) {
      push @a, $_ if (($2 != $3) && ($s[$3][$4] == 1));
    }
    else {
      push @a, $_;
    }
  }
close F;

open F, '>', $f;
print F for @a;
close F;

sub help {
  print <<EOH;
Usage:
  clean.pl <Monitor-file>

Defaults:
  Monitor-file :: $MONITOR_FILE
EOH
}
