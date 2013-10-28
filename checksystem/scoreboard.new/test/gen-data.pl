#!/usr/bin/perl

use JSON;
use strict;

@ARGV==2 or die "Usage: ./gen-data.pl <count> <out-dir>\n";

my ($COUNT, $DIR) = @ARGV;

my @status = qw/up up up up down down mumble corrupt/;

my %services = (
        "1" => "buster",
        "2" => "booking",
        "3" => "flightprocess",
        "4" => "flybook",
        "5" => "gds",
        "6" => "geotracker",
        "7" => "lust",
        "8" => "mch"
);

my $a = {1 => "ok", 2 => "lala"};
my %teams;
while (<DATA>) {
	chomp;
	my ($id,$name)=split/;/;
	$teams{$id}=$name;
	last if $. == $COUNT;
}

open T, ">$DIR/teams.json" or die;
print T to_json(\%teams, {pretty => 1});
close T;
print "$DIR/teams.json written ($COUNT)\n";

my %status;
for my $t (keys %teams) {
	my $stat = {};
	for my $s (keys %services) {
		$stat->{$s} = $status[int rand @status];
	}
	$status{$t} = $stat;
}

open T, ">$DIR/status.json" or die;
print T to_json(\%status, {pretty => 0});
close T;
print "$DIR/status.json written ($COUNT)\n";

__DATA__
1;Hanoiati
2;mlp
3;anesec
4;Bitmap
5;dcua
6;squareroots
7;xpuzzle
8;[TechnoPandas]
9;PeterPEN
10;SiBears
11;RDot.Org
12;Lobotomy
13;NULL Life
14;IngloriousMonkeys
15;More Smoked Leet Chicken
16;Bushwhackers
17;Hackademics
18;alcapwn
19;Big-Daddy
20;FluxFingers
21;LSE
22;MiSec
23;RPISEC
24;CAG
25;brooklynt overflow
26;Honeypot
27;0ldEur0pe
28;ENOFLAG
29;WizardsOfDos
30;BAD Magic
31;SlashDotDash
32;Yozik
33;bi0s
34;dummyteam
35;HackerMayCry
36;fangAflaggaN
37;xbios
38;ufologists
39;brains_404
40;secv1.0
41;h34dump
42;sutegoma2
43;VUBAR
44;GIRAV
45;lesboverflows
46;rhccdc
47;[keva]
48;Eindbazen
49;Medve_Plush
50;int3pids
51;We_0wn_Y0u
52;w3b0n3s
53;gn00bz
54;Local Maximum
55;Tracer Tea
56;CLGT
57;Noobs4Win
58;Bilanz
59;xBh
60;blue-lotus
61;p03p0wn
62;tasteless
63;0daysober
64;fail0verflow
65;HackClub
66;The DHARMA Initiative
67;MadHatters
68;PuN1sh3r
69;FIXME
70;Team AFK
71;c00kies@venice
72;f0gd0gs
73;WildRide
74;#Insanity
75;Glider Swirley
77;utdcsg
78;CCCAC
79;gula.sh
80;teampong
82;Defragmented Brains
83;tachiko.ma
84;LZ
85;tinpardo
86;XorBit
87;Ctrl-PNZ
88;[censored]
89;GLUM
90;0x90
91;We Are Scientists
92;Geek_Swag
93;N@sikBujanG
94;rndc
95;rm -rf
96;Windows Lovers
97;Team Reboot
98;Baghali
99;omtime
100;ind
101;IPWNU
102;Singularity
103;Dark Side
104;ZM4LW4R3
105;TheRoosevelt6
106;MEH
107;pwnies
108;valis
109;1338-offbyone
110;ForbiddenBITS
111;w0pr
112;doz
113;More Small Leet More
114;BeginBazen
115;Dystopian Knights
116;Chozodia
117;all about August
118;SsoMac
119;Nil_Team
120;LulzSec CTF Team
121;Native
122;ReallyNonamesFor
123;Mayonesa
124;Nomatter
125;NerdBalls
126;Violators
127;RingZer0
128;HSSF
129;calimero
130;PoisonedBytes
131;nanctf
132;P*wn Me I*m Famous
133;bitLust
138;Magic Koibasta Hat
139;*.*null
140;blah
141;simsim
142;OMGCTFTEAM
143;ICRS
144;MV9rwGOf08
