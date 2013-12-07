package SNG;

require Exporter;
use IPC::Open2;

our @ISA = qw/Exporter/;
our @EXPORT = qw/generate_simple_sng/;
our $VERSION = 1;

sub _IHDR {
	return <<EOH
IHDR {
  width: $_[0];
  height: $_[1];
  bitdepth: $_[2];
  $_[3];
}

EOH
}

sub generate_simple_sng {
	my $w = 128 + int rand 64;
	my $h = 128 + int rand 64;
	my $d = [8, 16]->[int rand 2];
	my $a = int rand 2;
	my $r = _IHDR ($w, $h, $d, 'using color' . ($a ? ' alpha' : '')) . "IMAGE {\n  pixels hex;\n";

	my $pat = ($d == 8 ? "%02x" : "%04x") x (3 + $a);
	$r .= "  " . (join ' ', map { sprintf $pat, int rand (1 << $d), int rand (1 << $d), int rand (1 << $d), int rand (1 << $d) } (1 .. $w)) . "\n" for 1 .. $h;

	"$r}";
}

sub uniq {
	my %h = map { ($_, '') } @_;
	keys %h;
}

sub generate_palette_sng {
	my $w = 128 + int rand 64;
	my $h = 128 + int rand 64;
	my $r = _IHDR ($w, $h, 8, 'using color palette');
	my $k = 64 + int rand 128;

	my @pal = uniq (map { sprintf "(%3s,%3s,%3s)", int rand 256, int rand 256, int rand 256 } 1 .. $k);
	$r .= "PLTE {\n" . (join '', map { "  $_\n" } @pal) . "}\n";

	my %hist;

	my $pic = "IMAGE {\n  pixels hex;\n";
	$pic .= (join '', map { my $x = int rand @pal; ++ $hist {$x}; sprintf "%02x", $x } (1 .. $w)) . "\n" for 1 .. $h;

	"${r}hIST {\n  " . (join (' ', map { $hist {$_} || '0' } (0 .. @pal - 1))) . ";\n}\n$pic}\n";
}

sub unparse_flag {
	my ($p, $v) = @_;

	my $pid = open2 (*FIN, *FOUT, "./extract '$v'");
	print FOUT $p;
	close FOUT;
	my $r = <FIN>;
	waitpid ($pid, 0);
	
	$r;
}

1;

