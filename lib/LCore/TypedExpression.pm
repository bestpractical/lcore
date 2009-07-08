package LCore::TypedExpression;
use Moose::Role;
use Scalar::Util 'looks_like_number';

sub get_procedure {
    my ($self, $env, $expression) = @_;

    if (ref($expression) eq 'LCore::Expression::Variable') {
        my $name = $expression->name;
        my $func = $env->get_symbol($name)
            or die "'$name' not defined";
        return ($func, $name);
    }
    elsif ($expression->isa('LCore::Expression::Lambda')) {
        return ($expression->procedure, '<lambda>');
    }
}

sub get_return_type {
    my ($self, $env) = @_;
    # XXX: cleanup and make each expression type return the correct
    # return_type
    if ($self->isa('LCore::Expression::Application')) {
        # for application, we attempt to get the actual function and
        # its return type.  we need to check if it is a lexical
        # variable, if so it is a lambda passed in and we need to
        # defer to type check
        my $operator = $self->operator;
        my ($func) = $self->get_procedure($env, $self->operator);
        return $func ? $func->return_type : undef;
    }
    elsif ($self->isa('LCore::Expression::Lambda')) {
        return 'Function';
    }
    elsif ($self->isa('LCore::Expression::SelfEvaluating')) {
        return looks_like_number $self->value ? 'Num' : 'Str';
    }
}

1;
