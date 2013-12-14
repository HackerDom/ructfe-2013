package Monitor;
use Mojo::Base 'Mojolicious';

use DBI;

has cache => sub { +{} };

sub startup {
  my $self = shift;

  my $mode = $self->mode;
  $self->plugin('Config', file => "monitor.$mode.conf");

  my $r = $self->routes;
  $r->get('/')->to('main#index');
  $r->get('/flags')->to('main#flags');

  $self->helper(
    db => sub {
      DBI->connect_cached(
        $self->config->{db}->{source},
        $self->config->{db}->{user},
        $self->config->{db}->{pass},
        {RaiseError => 1, AutoCommit => 1, pg_enable_utf8 => 1});
    });
}

1;
