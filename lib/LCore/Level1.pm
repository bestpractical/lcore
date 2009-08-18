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
                          },
                            return_type => 'ArrayRef',
                        ));

    # (a -> b) -> [a] -> [b]
    $self->set_symbol('map' => LCore::Primitive->new
                          ( lazy => 0, # this is one level force, for the list
                            slurpy => 1,
                            body => sub {
                                my ($func, $list) = @_;
                                return [map {$func->apply($_)} @$list];
                            },
                            parameters => [ LCore::Parameter->new({ name => 'func', type => 'Function' }),
                                            LCore::Parameter->new({ name => 'items', type => 'ArrayRef' }) ],
                            return_type => 'ArrayRef',
                        ));

    $self->set_symbol('and' => LCore::Primitive->new
                          ( body => sub {
                                my $i = 0;
                                for (@{$_[0]}) {
                                    if (!$_) {
                                        return 0;
                                    }
                                }
                                return 1;
                            },
                            parameters => [ LCore::Parameter->new({ name => 'conditions', type => 'ArrayRef[Bool]' })],
                            return_type => 'Bool' ));

    $self->set_symbol('or' => LCore::Primitive->new
                          ( body => sub {
                                for (@{$_[0]}) {
                                    if ($_) {
                                        return 1;
                                    }
                                }
                                return 0;
                            },
                            parameters => [ LCore::Parameter->new({ name => 'conditions', type => 'ArrayRef[Bool]' })],
                            return_type => 'Bool'));

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


1;
