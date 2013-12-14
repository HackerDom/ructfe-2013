package Monitor::Main;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

  my $db = $self->db;

  my $flag_points = $self->_flag_points;
  my $sla_points  = $self->_sla_points;

  my @teams;
  my $teams = $self->_teams;
  for my $tid (keys %$teams) {
    my $team = $teams->{$tid};
    my $fp   = $flag_points->{$tid} // 0;
    my $sla  = $sla_points->{$tid} // 0;

    push @teams,
      {
      tid     => $tid,
      name    => $team->{name},
      network => $team->{network},
      fp      => $fp,
      sla     => $sla,
      score   => $fp * $sla
      };
  }
  @teams = sort { $b->{score} <=> $a->{score} } @teams;

  $self->stash(teams    => \@teams);
  $self->stash(services => $self->_service_status);
  $self->stash(round    => $self->_round);
  $self->render;
}

sub flags {
  my $self = shift;

  $self->stash(flags    => $self->_flags);
  $self->stash(services => $self->_services);
  $self->stash(teams    => $self->_teams);
  $self->stash(round    => $self->_round);
  $self->render;
}

sub _flag_points {
  my $self = shift;
  my $flag_points;
  my $db = $self->db;

  my $fp = $self->app->cache->{fp};
  if ($fp && $fp->{expires} > time) {
    $flag_points = $fp->{data};
  } else {
    my $stm = $db->prepare(
      q{
      SELECT DISTINCT ON (team) team AS team_id, score
      FROM score ORDER BY team, time DESC
    }
    );
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    while (my $row = $stm->fetchrow_hashref()) {
      $flag_points->{$row->{team_id}} = $row->{score};
    }

    my $cache = $self->app->cache;
    $cache->{fp} = {expires => 60 + time, data => $flag_points};
    $self->app->cache($cache);
  }

  return $flag_points;
}

sub _sla_points {
  my $self = shift;
  my $sla_points;
  my $db = $self->db;

  my $sla = $self->app->cache->{sla};
  if ($sla && $sla->{expires} > time) {
    $sla_points = $sla->{data};
  } else {
    my $stm = $db->prepare(
      q{
      SELECT DISTINCT ON (team_id) team_id, successed, failed
      FROM sla ORDER BY team_id, time DESC;
    }
    );
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    while (my $row = $stm->fetchrow_hashref()) {
      my ($sla, $sum) = (0, $row->{successed} + $row->{failed});
      $sla = $row->{successed} / $sum if $sum > 0;
      $sla_points->{$row->{team_id}} = $sla;
    }

    my $cache = $self->app->cache;
    $cache->{sla} = {expires => 60 + time, data => $sla_points};
    $self->app->cache($cache);
  }

  return $sla_points;
}

sub _teams {
  my $self = shift;
  my $teams;
  my $db = $self->db;

  my $t = $self->app->cache->{t};
  if ($t && $t->{expires} > time) {
    $teams = $t->{data};
  } else {
    my $stm = $db->prepare('SELECT id, name, network FROM teams;');
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    while (my $row = $stm->fetchrow_hashref()) {
      $teams->{$row->{id}} = $row;
    }

    my $cache = $self->app->cache;
    $cache->{t} = {expires => 60 * 10 + time, data => $teams};
    $self->app->cache($cache);
  }

  return $teams;
}

sub _service_status {
  my $self = shift;
  my $services;
  my $db = $self->db;

  my $ss = $self->app->cache->{ss};
  if ($ss && $ss->{expires} > time) {
    $services = $ss->{data};
  } else {
    my $stm = $db->prepare('SELECT team_id, service, status, fail_comment FROM service_status;');
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    while (my $row = $stm->fetchrow_hashref()) {
      $services->{$row->{service}}{$row->{team_id}} = $row;
    }

    my $cache = $self->app->cache;
    $cache->{ss} = {expires => 60 + time, data => $services};
    $self->app->cache($cache);
  }

  return $services;
}

sub _flags {
  my $self = shift;
  my $flags;
  my $db = $self->db;

  my $f = $self->app->cache->{f};
  if ($f && $f->{expires} > time) {
    $flags = $f->{data};
  } else {
    my $stm = $db->prepare('SELECT * FROM services_flags_stolen score;');
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    while (my $row = $stm->fetchrow_hashref()) {
      $flags->{$row->{team}}{$row->{service}} = $row->{flags};
    }

    my $cache = $self->app->cache;
    $cache->{f} = {expires => 60 + time, data => $flags};
    $self->app->cache($cache);
  }

  return $flags;
}

sub _services {
  my $self = shift;
  my $services;
  my $db = $self->db;

  my $s = $self->app->cache->{s};
  if ($s && $s->{expires} > time) {
    $services = $s->{data};
  } else {
    my $stm = $db->prepare('SELECT name FROM services;');
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    while (my $row = $stm->fetchrow_hashref()) {
      push @$services, $row->{name};
    }

    my $cache = $self->app->cache;
    $cache->{s} = {expires => 60 * 10 + time, data => $services};
    $self->app->cache($cache);
  }

  return $services;
}

sub _round {
  my $self = shift;
  my $round;
  my $db = $self->db;

  my $r = $self->app->cache->{r};
  if ($r && $r->{expires} > time) {
    $round = $r->{data};
  } else {
    my $stm = $db->prepare('SELECT n, EXTRACT(EPOCH FROM time) AS time FROM rounds ORDER BY n DESC LIMIT 1');
    $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
    my $row = $stm->fetchrow_hashref();
    $round = {n => $row->{n}, time => scalar gmtime int $row->{time}};

    my $cache = $self->app->cache;
    $cache->{r} = {expires => 20 + time, data => $round};
    $self->app->cache($cache);
  }

  return $round;
}

1;
