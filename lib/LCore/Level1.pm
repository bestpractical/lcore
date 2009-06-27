package LCore::Level1;
use Moose;
use LCore;

extends 'LCore::Env';

has '+parent' => (default => sub { LCore->global_env });

sub BUILD {
    my ($self, $params) = @_;

    $self->set_symbol('if' =>
                          bless sub {
                              my ($predicate, $true, $false) = @_;
                              return $predicate ? $true : $false;
                          }, 'LCore::Lazy' );

    $self->set_symbol('list' =>
                          bless sub {
                              return [@_];
                          }, 'LCore::Lazy' );

    $self->set_symbol('map' =>
                          bless sub {
                              my ($func, $list) = @_;
                              return [map {$func->($_)} @$list];
                          }, 'LCore::Primitive' );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


1;
