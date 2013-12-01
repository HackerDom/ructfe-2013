package SNG;

require Exporter;
use IPC::Open2;

our @ISA = qw/Exporter/;
our @EXPORT = qw/generate_simple_sng/;
our $VERSION = 1;

sub generate_simple_sng {
	my $w = 128 + int rand 64;
	my $h = 128 + int rand 64;

	my $r = "IHDR {\nwidth: $w; height: $h; bitdepth: 8;\nusing color;\n}\nIMAGE {\npixels hex\n";

	for (1 .. $h) {
		$r .= (join ' ', map { sprintf "%02x%02x%02x", int rand 256, int rand 256, int rand 256 } (1 .. $w)) . "\n";
	}

	$r . '}';
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

