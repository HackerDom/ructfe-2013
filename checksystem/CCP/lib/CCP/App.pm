package CCP::App;
use Dancer ':syntax';
use DBI;
use Sys::Hostname;
use strict;

our $VERSION = '0.1';

my $dbh = session('dbh');

my %EXIT_CODES = ( 101 => 'UP', 102 => 'NOFL', 103 => 'MUMB', 104 => 'DOWN' );

#######################################
prefix undef;
#######################################

get '/' => sub {
    template 'index', {
		pid_Checksystem => `/usr/bin/pgrep -f ructf.main.Checksystem` || 'DOWN',
		pid_RoundsCache => `/usr/bin/pgrep -f ructf.roundsCache.Main` || 'DOWN',
		pid_SecureFlags => `/usr/bin/pgrep -f ructf.secureflags.Main` || 'DOWN',
		pid_GetFlags    => `/usr/bin/pgrep -f ructf.getflags.Main`    || 'DOWN',
		hostname        => hostname(),
		localtime	=> scalar localtime(),
	};
};

get '/teams' => sub {
    template 'teams';
};

get '/services' => sub {
    template 'services';
};

get '/logs' => sub {
    template 'logs';
};

any '/logs/view' => sub {
    template 'logs';
};

#######################################
prefix '/ajax';
#######################################

get '/' => sub {
	return "Nope.";
};

get '/teams' => sub {
	db_connect();
	return json(db_readhash('teams', 'id', 'name'));
};

get '/teams/detail' => sub {
	db_connect();
	return db_readtable('SELECT id, name, network, vuln_box FROM teams');
};

get '/services' => sub {
	db_connect();
	return json(db_readhash('services', 'id', 'name'));
};

get '/services/detail' => sub {
	db_connect();
	return db_readtable('SELECT id, name, checker FROM services');
};

post '/services/add' => sub {
	db_connect();
	my ($id,$name,$checker) = (params->{id}, params->{name}, params->{checker});
	$id =~ s/[^0-9]//g;
	$name =~ s/['",\\]//g;
	$checker =~ s/['",\\]//g;
	my $r = $dbh->do("INSERT INTO services(id,name,checker,delay_flag_get) VALUES (?,?,?,?)", {}, $id, $name, $checker, false);
	return 1;
};

any '/log' => sub {
	db_connect();
	my ($t,$s,$c,$r) = (params->{team}, params->{service}, params->{logcount}, params->{result});
	my $tt = $t=~/^\d+$/ ? "team_id=$t"    : "true";
	my $ss = $s=~/^\d+$/ ? "service_id=$s" : "true";
	my $rr = $r=~/^\d+$/ ? "retval=$r"     : "true";
	$rr = '(retval<101 OR retval>104)' if $r eq 'other';
	$rr = 'retval != 101'              if $r eq 'not101';
	my $cc = $c=~/^\d+$/ ? "LIMIT $c"      : "";
	my $sth = $dbh->prepare("SELECT * FROM checker_run_log WHERE $tt AND $ss AND $rr ORDER BY time DESC $cc");
	$sth->execute();
	my $result = '';
	while(my $arr = $sth->fetchrow_arrayref) {
		$arr->[1] =~ s/\.\d+$//;
		$arr->[6] .= "/".$EXIT_CODES{$arr->[6]} if exists $EXIT_CODES{$arr->[6]};
		$arr->[8] = "<pre>".$arr->[8]."</pre>";
		$result .= '<tr><td>'.(join '</td><td>', @{$arr})."</td></tr>\r\n";
	}
	return $result;
};

get '/gitpull' => sub {
	my $git_src = config->{git_src};
	my $git_dst = config->{git_dst};

	# Check dirs for existence
	-d $git_src or send_error("git_src not found", 404);
	-d $git_dst or send_error("git_dst not found", 404);

	# Pull from git
	$ENV{GIT_ASKPASS} = config->{git_askpass};
	my $out = `cd $git_src && git pull 2>&1`;
	($?>>8) and send_error("git pull failed: $out", 500);
	$ENV{GIT_ASKPASS} = '';

	# Copy from git dir to checksystem dir
	my $out2 = `cp -v -r $git_src/* $git_dst`;
	($?>>8) and send_error("copy failed: $out", 500);

	return localtime()."\r\n".
		"From: $git_src\r\n". 
		"$out\r\n".
		$out2;
};

return true;

#######################################

sub db_connect {
	return if defined $dbh;
	my $connstr = sprintf "DBI:Pg:dbname=%s;host=%s;port=%d", config->{db_name}, config->{db_host}, config->{db_port};
	$dbh = DBI->connect($connstr, config->{db_user}, config->{db_pass}, {'RaiseError' => 1});
	session 'dbh' => $dbh;
}

sub db_readtable {
	my $sql = shift;
	my $result;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my $arr = $sth->fetchrow_arrayref) {
		$result .= '<tr><td>'.(join '</td><td>', @{$arr})."</td></tr>\r\n";
	}
	return $result;
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

sub json {
	my %in = @_;
	return "{" . join(',', map {"\"$_\":\"$in{$_}\""} sort keys %in) . "}";
}

