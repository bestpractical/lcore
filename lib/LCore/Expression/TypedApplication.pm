package LCore::Expression::TypedApplication;
use Moose::Role;
with 'LCore::TypedExpression';

before 'mk_expression' => sub {
    my ($self, $env, $operator, $operands) = @_;

    my ($func, $name) = $self->get_procedure($env, $operator) or return;

    my @args = $self->get_operands($func, $operands);

    if (my $params = $func->parameters) {
        die "argument number mismatch for $name" if $#{$params} ne $#args;
        for (0..$#args) {
            my $expected = $params->[$_]->type or next;
            next unless UNIVERSAL::can($args[$_], 'get_return_type');
            if (my $incoming = $args[$_]->get_return_type($env)) {
                die "type mismatch for '$name' parameters @{[ 1 + $_ ]}: expecting $expected, got $incoming"
                    if $incoming ne $expected;
            }
        }
    }
};

no Moose;
1;
