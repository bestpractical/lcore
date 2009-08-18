package LCore::Expression::TypedApplication;
use Moose::Role;
with 'LCore::TypedExpression';

around 'get_operands' => sub {
    my ($next, $self, $env, $proc, $operands) = @_;
    my @args = $self->$next($env, $proc, $operands);

    if ($proc->parameters && $proc->slurpy) {
        # auto arraify
        my @params = @{$proc->parameters};
        die 'slurpy arg should be arrayref'
            unless $params[-1]->type =~ m/^ArrayRef/;
        if ($#args == $#params) {
            return @args unless UNIVERSAL::can($args[-1], 'get_return_type');
            if (my $incoming = $args[-1]->get_return_type($env)) {
                return @args if $incoming =~ m/^ArrayRef/;
            }
        }
        if ($#args >= $#params) {
            my @arraify = @args[$#params..$#args];
            my $x = sub { my $env = shift; [map { $_->($env) } @arraify] };
            splice(@args, $#params);
            push @args, $x;
        }
    }
    return @args;
};

use Moose::Util::TypeConstraints qw(type find_type_constraint);

type 'Function';

before 'mk_expression' => sub {
    my ($self, $env, $operator, $operands) = @_;

    my ($func, $name) = $self->get_procedure($env, $operator) or return;

    my @args = $self->get_operands($env, $func, $operands);

    if (my $params = $func->parameters) {
        die "argument number mismatch for $name" if $#{$params} ne $#args;
        for (0..$#args) {
            my $expected = $params->[$_]->type or next;
            next unless UNIVERSAL::can($args[$_], 'get_return_type');
            if (my $incoming = $args[$_]->get_return_type($env)) {
                ($incoming, $expected) = map { find_type_constraint($_) || $_ } ($incoming, $expected);
                warn "not registered $incoming" unless ref($incoming);
                warn "not registered $expected" unless ref($expected);
                die "type mismatch for '$name' parameters @{[ 1 + $_ ]}: expecting $expected, got $incoming"
                    unless $incoming->is_a_type_of($expected);

            }
        }
    }
};

no Moose;
1;
