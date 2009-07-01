package LCore::Procedure;
use Moose;

has env => (is => "ro", isa => "LCore::Env");
has body => (is => "ro", isa => "CodeRef|LCore::Expression");
has parameters => (is => "ro", isa => "ArrayRef");
has return_type => (is => "rw", isa => "Str");
has lazy => (is => "ro", isa => "Bool", default => sub { 1 });

BEGIN {
use overload (
        fallback => 1,
        '&{}' => sub { my $self = shift; sub { $self->apply(@_) } },
    );
}

sub BUILD {
    my ($self, $params) = @_;
    return unless $self->body->does('LCore::TypedExpression');
    return unless ref($self->body) && $self->body->isa('LCore::Expression::Application');
    # this belongs to "guess type from LCore::Expression::Application"
    my $operator = $self->body->operator;
    if (ref($operator) eq 'LCore::Expression::Variable') {
        my $symbol = $self->env->get_symbol($operator->name)
            or die 'blah';
        # XXX: push type info into the expression for forward checking
        return unless $symbol->return_type;
        if ($self->return_type) {
            die "return type mismatch: expecting @{[ $self->return_type]} but got @{[ $symbol->return_type ]} from expression"
                if $self->return_type ne $symbol->return_type;
        }
        else {
            $self->return_type( $symbol->return_type );
        }
    }

}

sub apply {
    my ($self, @args) = @_;

    die "argument number mismatch" if $#{$self->parameters} ne $#args;
    my %args = map { $_ => shift @args } @{$self->parameters};
    return $self->body->($self->env->extend(\%args));
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
