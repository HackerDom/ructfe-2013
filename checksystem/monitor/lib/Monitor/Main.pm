package Monitor::Main;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

  my $db = $self->db;
  my ($flag_points, $sla_points, $teams, @teams, $services);

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

  $stm = $db->prepare(
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

  $stm = $db->prepare('SELECT id, name, network FROM teams;');
  $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
  while (my $row = $stm->fetchrow_hashref()) {
    $teams->{$row->{id}} = $row;
  }

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

  $stm = $db->prepare('SELECT team_id, service, status, fail_comment FROM service_status;');
  $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
  while (my $row = $stm->fetchrow_hashref()) {
    $services->{$row->{service}}{$row->{team_id}} = $row;
  }

  $self->stash(teams    => \@teams);
  $self->stash(services => $services);
  $self->render;
}

sub flags {
  my $self = shift;

  my $db = $self->db;
  my ($flags, @services);

  my $stm = $db->prepare('SELECT * FROM services_flags_stolen score;');
  $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
  while (my $row = $stm->fetchrow_hashref()) {
    $flags->{$row->{team}}{$row->{service}} = $row->{flags};
  }

  $stm = $db->prepare('SELECT name FROM services;');
  $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
  while (my $row = $stm->fetchrow_hashref()) {
    push @services, $row->{name};
  }

  $self->stash(flags    => $flags);
  $self->stash(services => \@services);
  $self->stash(teams    => $self->_teams);
  $self->render;
}

sub _teams {
  my $self = shift;
  my $teams;

  my $db = $self->db;
  my $stm = $db->prepare('SELECT id, name, network FROM teams;');
  $stm->execute() or $self->app->log->warn("SQL error [$DBI::err]: $DBI::errstr");
  while (my $row = $stm->fetchrow_hashref()) {
    $teams->{$row->{id}} = $row;
  }

  return $teams;
};


1;
