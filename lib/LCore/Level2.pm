package LCore::Level2;
use Moose;
use LCore;
use LCore::Primitive;
use MooseX::ClassAttribute;
use Scalar::Util 'looks_like_number';

extends 'LCore::Level1';

sub analyze_application {
    my ($self, $exp) = @_;

    return unless ref($exp) eq 'ARRAY';

    my ($op, @exp) = @$exp;
    my $operator = $self->analyze($op);
    my @args = map { $self->analyze($_) } @exp;

    if (ref($operator) eq 'LCore::Expression::Variable') {
        my $symbol = $self->get_symbol($operator->name)
            or die "'$op' not defined";
        if (my $params = $symbol->parameters) {
            die "argument number mismatch for @{[ $operator->name ]}" if $#{$params} ne $#args;
            for (0..$#args) {
                my $expected = $params->[$_]->type;
                if (my $incoming = $self->get_type_from_expression($args[$_])) {
                    die "type mismatch for '@{[ $operator->name ]}' parameters @{[ 1 + $_ ]}: expecting $expected, got $incoming"
                        if $incoming ne $expected;
                }
            }
        }
    }
    return sub {
        my $env = shift;
        my $o = $operator->($env) or die "can't find operator";
        my @a = $o->lazy
            ? map { ref $_ ? LCore::Thunk->new( env => $env, delayed => $_ ): $_ } @args
            : map { $_->($env) } @args;

        return $o->(@a);
    }

}

sub get_type_from_expression {
    my ($self, $node) = @_;
    if ($node->isa('LCore::Expression::SelfEvaluating')) {
        return looks_like_number $node->value ? 'Num' : 'Str';
    }
}

sub BUILD {
    my ($self, $params) = @_;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


1;
