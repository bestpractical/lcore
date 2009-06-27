package LCore::Level1;
use Moose;
use LCore;
use MooseX::ClassAttribute;

extends 'LCore::Env';

has '+parent' => (default => sub { LCore->global_env });

class_has '+analyzers' => (
    default => sub { [ qw(self_evaluating variable lambda application)] },
);

sub analyze_lambda {
    my ($self, $exp) = @_;
    return unless ref($exp) eq 'ARRAY' && $exp->[0] eq 'lambda';

    my (undef, $params, $body) = @$exp;

    die 'param error' unless ref($params) eq 'ARRAY';

    my $lambda_body = $self->analyze($body);

    return sub {
        my $env = shift;
        LCore::Procedure->new( { env => $env,
                                 body => $lambda_body,
                                 parameters => $params } );
    };

    die Dumper($exp); use Data::Dumper;


}

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
