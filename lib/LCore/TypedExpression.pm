package LCore::TypedExpression;
use Moose::Role;

sub get_return_type {
    my ($self, $env) = @_;
    # XXX: cleanup and make each expression type return the correct
    # return_type
    if ($self->isa('LCore::Expression::Application')) {
        # for application, we attempt to get the operator and its return type
        my $operator = $self->operator;
        if (ref($operator) eq 'LCore::Expression::Variable') {
            my $symbol = $env->get_symbol($operator->name)
                or die 'blah';
            return $symbol->return_type;
        }
    }
}

1;
