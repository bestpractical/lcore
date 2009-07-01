package LCore::Env;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::ClassAttribute;
use LCore::Expression::Variable;
use LCore::Expression::SelfEvaluating;
use LCore::Expression::Application;

=head1 NAME

LCore::Env - 

=head1 SYNOPSIS



=head1 DESCRIPTION

This is the environment class for a lcore runtime.  the root
environment object of an lcore evaluator serves as the repository of
language features, including expressions supported and primitive
functions available.  L<LCore::Env> basically is nothing but an
evaluator.  there is no function defined by default.  See
L<LCore::Level1> and L<LCore::Level2>.

=cut

class_has 'analyzers' => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [ qw(self_evaluating variable application)] },
);

has parent => (is => "ro", isa => "LCore::Env");

has symbols => (
    metaclass => 'Collection::Hash',
    is => "ro",
    isa => "HashRef",
    default => sub { {} },
    provides  => {
        'set'    => 'set_symbol',
        'get'    => 'get_symbol',
        'exists' => 'has_symbol',
    },
);

sub get_value {
    my $self = shift;
    my $name = shift;
    my $env = $self;
    while ($env) {
        return $env->get_symbol($name) if $env->has_symbol($name);
        $env = $env->parent;
    }
}

sub extend {
    my $self = shift;
    my $vars = shift;
    return __PACKAGE__->new( symbols => { %$vars }, parent => $self );
}

sub analyze_self_evaluating {
    my ($self, $exp) = @_;
    return if ref($exp);

    return LCore::Expression::SelfEvaluating->new( code => sub { $exp },
                                                   value => $exp );
}


sub analyze_variable {
    my ($self, $exp) = @_;
    return unless (ref($exp) && ref($exp) eq 'Data::SExpression::Symbol');

    return LCore::Expression::Variable->new
        ( name => "$exp",
          code => sub { my $env = shift;
                        $env->get_value($exp);
                    } );
}

sub analyze_application {
    my ($self, $exp) = @_;

    return LCore::Expression::Application->analyze($self, $exp);
}

sub analyze {
    my ($self, $exp) = @_;
    my $result;

    my @expression_type = @{$self->analyzers};
    for (@expression_type) {
        my $func = $self->can("analyze_$_");
        my $ret = $self->$func( $exp );
        return $ret if $ret;
    }
    die "unknown expression type".Dumper($exp);use Data::Dumper;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

