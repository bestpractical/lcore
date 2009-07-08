package LCore::Level1;
use Moose;
use LCore;
use LCore::Primitive;
use LCore::Expression::Lambda;
use MooseX::ClassAttribute;

extends 'LCore::Env';

has '+parent' => (default => sub { LCore->global_env });

class_has '+analyzers' => (
    default => sub { [ qw(self_evaluating variable lambda application)] },
);

sub analyze_lambda {
    my ($self, $exp) = @_;

    return LCore::Expression::Lambda->analyze($self, $exp);
}

sub BUILD {
    my ($self, $params) = @_;

    $self->set_symbol('if' => LCore::Primitive->new
                          ( body => sub {
                                my ($predicate, $true, $false) = @_;
                                return $predicate ? $true : $false;
                            }));

    $self->set_symbol('list' => LCore::Primitive->new
                          ( body => sub {
                              return [@_];
                          }));

    $self->set_symbol('map' => LCore::Primitive->new
                          ( lazy => 0,
                            body => sub {
                                my ($func, $list) = @_;
                                return [map {$func->apply($_)} @$list];
                            }));
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


1;
