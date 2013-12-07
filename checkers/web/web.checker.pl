#!/usr/bin/perl -lw
use 5.10.0;
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Upload;

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
        my ($ua, $um, $up, $utype) = @_;
        $url->path('/index.php');
	$url->query(action=>'login');
        warn "Try login '$utype' '$um' with password '$up'";    
	my $res;
	my $check_str;
	if($utype eq 'company')
	{
		$res = $ua->post($url, form => {type => $utype, email => $um, passwd => $up})->res;
       		$check_str = '<ul class=\'nav\'><li><a href="index.php?action=info_company">'.$um.'</a></li><li><a href="index.php?action=acct_company">ACCT</a></li><li><a href="index.php?action=logout" class="exit">';
	}
	else
	{
		$res = $ua->post($url, form => {email => $um, passwd => $up})->res;
		$check_str = '<ul class=\'nav\'><li><a href="index.php?action=info_user">'.$um.'</a></li><li><a href="index.php?action=acct_user">ACCT</a></li><li><a href="index.php?action=logout" class="exit">';
	}
	$check_error->($res);
        my $code = $res -> code;
	unless($code == 200)
	{
	        print 'Login fail';
                exit $SERVICE_CORRUPT;
	} 
	$url->query(Mojo::Parameters->new);
	$res = $ua->get($url)->res;
	$check_error -> ($res);
	$code = $res -> code;
	my $content = $res -> content;
        unless((defined $code) and ($code == 200) and ($content->body_contains($check_str)))
	{
                print 'Login fail';
                exit $SERVICE_CORRUPT;
        }
        warn 'Login successful';
};

my $register = sub {
	my ($uagent, %up) = @_; 
	
	$url->path('/index.php');
	$url->query(action=>'registration');
        warn "Try register user '$up{'mail'}' with password '$up{'pass'}'";
       
	my $res = $uagent->post($url, form => { passwd => $up{'pass'}, repassword => $up{'pass'}, email => $up{'mail'}, type_table => $up{'type'}})->res;
        
	my $code = $res-> code;
	my $content = $res -> content;
	unless ((defined $code) and ($code == 200) and $content->body_contains('div class="nav-collapse collapse">')) 
	{
                print 'Registration first step fail';
                warn 'Registration first step fail';
                exit $SERVICE_CORRUPT;
        }

	my $check_str;	
	
	if($up{'type'} eq 'user')
	{    	
		$url->query(action=>'reg_user');
        	warn "Continue register '$up{'type'}' '$up{'mail'}' with password '$up{'pass'}' and flag '$up{'max_sum'}'";
		$res = $uagent -> post($url, form => {name => $up{'name'}, surname => $up{'surname'}, country => $up{'country'}, birthday => $up{'birthday'}, numbers => $up{'phone'}, max_sum => $up{'max_sum'}, type => $up{'card_type'}, doc => { filename => $up{'filename'}, content => 'SimpleText' } })->res;
		$check_str = '<ul class=\'nav\'><li><a href="index.php?action=info_user">'.$up{'mail'}.'</a></li><li><a href="index.php?action=acct_user">ACCT</a></li><li><a href="index.php?action=logout" class="exit">';
	}
	if($up{'type'} eq 'company')
	{
		$url->query(action=>'reg_company');
	        warn "Continue register '$up{'type'}' '$up{'name'}' with password '$up{'pass'}' and flag '$up{'max_sum'}'";
		$res = $uagent -> post($url, form => {name_company => $up{'name'}, country => $up{'country'}, address => $up{'addr'}, created => $up{'date'}, numbers => $up{'phone'}, owner => $up{'owner'}, max_sum => $up{'max_sum'}, type => $up{'card_type'}, doc => {filename => $up{'filename'}, content => 'SimpleText'}}) -> res;
		$check_str = '<ul class=\'nav\'><li><a href="index.php?action=info_company">'.$up{'mail'}.'</a></li><li><a href="index.php?action=acct_company">ACCT</a></li><li><a href="index.php?action=logout" class="exit">';
	}
        $code = $res -> code;
	$content = $res -> content;
	unless((defined $code) and ($code == 200) and ($content->body_contains($check_str)))
	{
		print 'Registration second step fail';
                warn 'Registration second step fail';
		warn $check_str;
                exit $SERVICE_CORRUPT;
	} 
	warn 'Registration successful';
}; 

my $create_card = sub
{
	my ($ua, $um, $usum,$utype) = @_;
        $url->path('/index.php');
        $url->query(action=>'addacct');
        warn "Try add card user '$um' with sum '$usum'";
        my $res = $ua->post($url, form => {summ => $usum, type => $utype})->res;
        $check_error->($res);
        my $code = $res -> code;
        unless($code == 200)
        {
                print 'Add cart fail';
                exit $SERVICE_CORRUPT;
        }
	warn 'Add card successful';
};

my $check_doc_name = sub
{
	my ($ua, $docname, $acc_type) = @_;
	$url -> query(action => 'info_'.$acc_type);
	warn "Check filename";
	my $res = $ua -> get($url) -> res;
	$check_error -> ($res);
	my $code = $res -> code;
	my $content = $res -> content -> get_body_chunk(0);
	$content =~ /<p>Doc:\s+(.*)<\/p>/;
	unless($code == 200 and $docname eq $1)
	{
		print "Check filename doc fail. Expect: $docname, but received $1.";
		exit $SERVICE_CORRUPT;
	} 
	warn 'Check filename successful';
};

my $check_max_sum = sub
{
	my ($ua, $max_sum, $acc_type) = @_;
	$url -> query(action => 'acct_'.$acc_type);
	warn "Check max_sum";
	my $res = $ua -> get($url) -> res;
	$check_error -> ($res);
	my $code = $res -> code;
	my $content = $res -> content -> get_body_chunk(0);
	$content =~ /\<tbody\>\s+\<tr\>\<td\>\d+\<\/td\>\<td\>.+\<\/td\>\<td\>.*\<\/td\>\<td\>(.*)\<\/td\>\<\/tr\>/;
	unless($code == 200 and $max_sum eq $1.'=')
	{
		print "Check max_sum fail. Expect: $max_sum, but received $1";
		exit $SERVICE_CORRUPT;
	}
	warn 'Check max_sum successfull';
};

$MODES{$mode}->(@ARGV);
exit $SERVICE_OK;

sub check 
{	
	warn "check $ip";
	my $uagent = Mojo::UserAgent->new();
        $url->path('/');
	$register->($uagent, name => rname(), surname =>  rname(), pass => rname(), type => 'user', mail => rname().'@'.rname(), country => rname(), phone => '1111',birthday =>  '11.11.1111', max_sum => rname(), card_type => 'visa', filename => 'doc.jpeg');
	exit $SERVICE_OK;  
}

sub put 
{
	my ($id, $flag) = @_;
	warn "put $ip $id $flag";
        my $ua = Mojo::UserAgent->new();
	my $type_flag = int(rand(3));
	
	my ($upass, $ucountry, $uphone, $ufilename) = (rname(), rname(), '00000000', rname().'jpeg');
	my $ucard_type;
        if(int(rand(2)) == 0) {$ucard_type = 'visa'} else {$ucard_type = 'mcard'}


	if($type_flag == 0)
	{
		chop $flag;
		my ($uname, $usurname, $umail, $ubirthday) = (rname(), rname(), rname().'@'.rname(), '01.01.1991');
		$register->($ua, name => $uname, surname => $usurname, pass => $upass, type => 'user', mail => $umail, country => $ucountry, phone => $uphone, birthday => $ubirthday, max_sum => $flag, card_type => $ucard_type, filename => $ufilename);
		print "0:$umail:$upass";
	}
	if($type_flag == 1)
	{
		chop $flag;
		my ($uname, $umail, $uaddr, $udate, $uowner) = (rname(), rname().'@'.rname(), rname(), '01.01.1991', rname());
		$register->($ua, name => $uname, pass => $upass, mail => $umail, country => $ucountry, addr => $uaddr, date => $udate, owner => $uowner, phone => $uphone, type => 'company', max_sum => $flag, filename => $ufilename, card_type => $ucard_type);
		print "1:$umail:$upass";		
	}	
	if($type_flag == 2)
	{
		if(int(rand(2)) == 0)
		{
		 	my ($uname, $umail, $uaddr, $udate, $uowner) = (rname(), rname().'@'.rname(), rname(), '01.01.1991', rname());
                	$register->($ua, name => $uname, pass => $upass, mail => $umail, country => $ucountry, addr => $uaddr, date => $udate, owner => $uowner, phone => $uphone, type => 'company', max_sum => rname(), filename => $flag, card_type => $ucard_type);
                	print "21:$umail:$upass";
		}
		else
		{
			my ($uname, $usurname, $umail, $ubirthday, $ufilename) = (rname(), rname(), rname().'@'.rname(), '01.01.1991', rname()."jpeg");
        	        $register->($ua, name => $uname, surname => $usurname, pass => $upass, type => 'user', mail => $umail, country => $ucountry, phone => $uphone, birthday => $ubirthday, max_sum => rname(), card_type => $ucard_type, filename => $flag);
		       	print "22:$umail:$upass";
		}
	}
}

sub get
{
	my ($id, $flag) = @_;

        my $ua = Mojo::UserAgent->new();

        my @id = split ':', $id;
        my ($flag_type, $um, $up) = splice @id, 0, 3;

	warn "Get $ip for $um and $up. Type - $flag_type";

	if($flag_type == 0 )
	{
        	$login -> ($ua, $um, $up, 'user');
		$check_max_sum -> ($ua, $flag, 'user');
	}
	if($flag_type == 1 )
	{
		$login -> ($ua, $um, $up, 'company');
		$check_max_sum -> ($ua, $flag, 'company');
	}
	if($flag_type == 22)
	{
		$login -> ($ua, $um, $up, 'user');
		$check_doc_name -> ($ua, $flag, 'user');	
	}
	if($flag_type == 21)
	{
		$login -> ($ua, $um, $up, 'company');
		$check_doc_name -> ($ua, $flag, 'company');
	}
	
	
	
	exit $SERVICE_OK;
}

sub rname {
        my $count = shift || 12;
        my $name = '';

        $name .= chr 97 + int rand 26  for (1 .. $count);
        return $name;
}
