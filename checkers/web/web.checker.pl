#!/usr/bin/perl -lw
use 5.10.0;
use Mojo::UserAgent;
use Mojo::URL;

my ($SERVICE_OK, $FLAG_GET_ERROR, $SERVICE_CORRUPT,
        $SERVICE_FAIL, $INTERNAL_ERROR) = (101, 102, 103, 104, 110);

my %MODES = (check => \&check, get => \&get, put => \&put);

my ($mode, $ip) = splice @ARGV, 0, 2;

unless (defined $mode and defined $ip) {
        warn "Invalid input data. Empty mode or ip address.";
        exit $INTERNAL_ERROR;
}

unless ($mode ~~ %MODES and $ip =~ /(\d{1,3}\.){3}\d{1,3}/) {
        warn "Invalid input data. Corrupt mode or ip address.";
        exit $INTERNAL_ERROR;
}

my $url = Mojo::URL->new();
$url->scheme('http');
$url->host($ip);
$url->port(80);

my $check_error = sub {
        my $res = shift;
        if ($res->error) {
                warn $res->error;
                print $res->error;
                exit $SERVICE_FAIL;
        }
};

my $login = sub {
        my ($ua, $um, $up) = @_;
        $url->path('/index.php');
	$url->query(action=>'login');
        warn "Try login user '$um' with password '$up'";
        my $res = $ua->post_form($url, {email => $um, passwd => $up})->res;
        $check_error->($res);
        my $code = $res -> code;
	unless($code == 200)
	{
	        print 'Login fail';
                exit $SERVICE_CORRUPT;
	} 
	$res = $ua->get($url)->res;
	$code = $res -> code;
	my $content = $res -> content;
        unless((defined $code) and ($code == 200) and ($content->body_contains('<ul class=\'nav\'><li><a href="index.php?action=info">'.$um.'</a></li><li><a href="index.php?action=acct">ACCT</a></li><li><a href="index.php?action=logout" class="exit">')))
	{
                print 'Login fail';
                exit $SERVICE_CORRUPT;
        }
        warn 'Login successful';
};

my $register = sub {
	my ($uagent, $uname, $upass, $utype, $umail, $ucountry, $utelephone, $ubirthday, $umax_sum, $ucard_type) = @_;
        $url->path('/index.php');
	$url->query(action=>'registration');
        warn "Try register user '$umail' with password '$upass'";
        my $res = $uagent->post_form($url, { passwd => $upass, repassword => $upass, email => $umail, doc => "", type_table => $utype})->res;
        $, = " ";

	my $code = $res-> code;
	my $content = $res -> content;
	unless ((defined $code) and ($code == 200) and $content->body_contains('div class="nav-collapse collapse">')) 
	{
                print 'Registration first step fail';
                warn 'Registration first step fail';
                exit $SERVICE_CORRUPT;
        }
	
	$url->query(action=>'reg_user');
        warn "Continue register user '$umail' with password '$upass' and flag '$umax_sum'";
        $res = $uagent->post_form($url, { email => $uname, country => $ucountry, birthday => $ubirthday, numbers => $utelephone, max_sum => $umax_sum, type => $ucard_type  })->res;
        $code = $res -> code;
	$content = $res -> content;
	unless((defined $code) and ($code == 200) and ($content->body_contains('<ul class=\'nav\'><li><a href="index.php?action=info">'.$umail.'</a></li><li><a href="index.php?action=acct">ACCT</a></li><li><a href="index.php?action=logout" class="exit">')))
	{
		print 'Registration second step fail';
                warn 'Registration second step fail';
                exit $SERVICE_CORRUPT;
	} 
	warn 'Registration successful';
}; 


$MODES{$mode}->(@ARGV);
exit $SERVICE_OK;

sub check 
{	
	warn "check $ip";
	my $uagent = Mojo::UserAgent->new();
        $url->path('/');
	$register->($uagent, rname(), rname(), 'User', rname().'@'.rname(), rname(), '1111', '11.11.1111', rname(), 'Visa');
	exit $SERVICE_OK;  
}
sub put 
{
	my ($id, $flag) = @_;
	warn "put $ip $id $flag";
        my $ua = Mojo::UserAgent->new();
	my ($un, $up, $um, $uc, $ut, $ub) = (rname(), rname(), rname().'@'.rname(), rname(), rname(), '01.01.1991');
	$register->($ua, $un, $up, 'User', $um, $uc, $ut, $ub, $flag, 'Visa');
	print "1:$um:$up";
}

sub get
{
	my ($id, $flag) = @_;

        my $ua = Mojo::UserAgent->new();

        my @id = split ':', $id;
        my ($flag_type, $um, $up) = splice @id, 0, 3;
        $login->($ua, $um, $up);
	
	#создать 2 счета и сделвть трансфер
	exit $SERVICE_OK;
}

sub rname {
        my $count = shift || 12;
        my $name = '';

        $name .= chr 97 + int rand 26  for (1 .. $count);
        return $name;
}

