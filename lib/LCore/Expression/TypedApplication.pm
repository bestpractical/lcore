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
            my $incoming = $self->_get_arg_return_type($env, $args[-1]);
            return @args if !$incoming || $incoming =~ m/^ArrayRef/;
        }
        if ($#args >= $#params) {
            my ($inner_type) = map { Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($_) }
                $params[-1]->type =~ m/ArrayRef\[(.*)\]/;
            my @arraify = @args[$#params..$#args];
            # XXX refactor to share with the type checking in mk_expression
            if ($inner_type) {
                for (0..$#arraify) {
                    my $incoming = $self->_get_arg_return_type($env, $arraify[$_])
                        or next;
                    die "type mismatch for array element @{[ 1 + $_ ]}: expecting $inner_type, got $incoming"
                        unless $incoming->is_a_type_of($inner_type);
                }
            }

            my $x = sub { my $env = shift; [map { $_->($env) } @arraify] };
            splice(@args, $#params);
            push @args, $x;
        }
    }
    return @args;
};

before 'mk_expression' => sub {
    my ($self, $env, $operator, $operands) = @_;

    my ($func, $name) = $self->get_procedure($env, $operator) or return;

    my @args = $self->get_operands($env, $func, $operands);

    my $params = $func->parameters or return;

    die "argument number mismatch for $name" if $#{$params} ne $#args;
    for (0..$#args) {
        my $expected = $params->[$_]->type or next;
        my $incoming = $self->_get_arg_return_type($env, $args[$_]) or next;

        die "type mismatch for '$name' parameters @{[ 1 + $_ ]}: expecting $expected, got $incoming"
            unless $incoming->is_a_type_of($expected);
    }
};

sub _get_arg_return_type {
    my ($self, $env, $arg) = @_;
    return unless UNIVERSAL::can($arg, 'get_return_type');
    my $r = $arg->get_return_type($env) or return;
    return Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( $r );
}

no Moose;
1;
