package LCore::Expression::TypedApplication;
use Moose::Role;
with 'LCore::TypedExpression';

before 'mk_expression' => sub {
    my ($self, $env, $operator, $operands) = @_;

    my @args = @$operands;
    if (ref($operator) eq 'LCore::Expression::Variable') {
        my $symbol = $env->get_symbol($operator->name)
            or die "'@{[ $operator->name ]}' not defined";
        if (my $params = $symbol->parameters) {
            die "argument number mismatch for @{[ $operator->name ]}" if $#{$params} ne $#args;
            for (0..$#args) {
                my $expected = $params->[$_]->type;
                next unless $args[$_]->can('get_return_type');
                if (my $incoming = $args[$_]->get_return_type($env)) {
                    die "type mismatch for '@{[ $operator->name ]}' parameters @{[ 1 + $_ ]}: expecting $expected, got $incoming"
                        if $incoming ne $expected;
                }
            }
        }
    }
};

no Moose;
1;
