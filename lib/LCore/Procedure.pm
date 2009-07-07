package LCore::Procedure;
use Moose;

with 'LCore::Function';

has env => (is => "ro", isa => "LCore::Env");
has body => (is => "ro", isa => "CodeRef|LCore::Expression");

sub BUILD {
    my ($self, $params) = @_;
    # if the lambda body has a return type we can derive, we would
    # ensure that works with the defined one here
    return unless $self->body->can('get_return_type');

    my $return_type = $self->body->get_return_type($self->env)
        or return;

    if ($self->return_type) {
        die "return type mismatch: expecting @{[ $self->return_type]} but got @{[ $return_type ]} from expression"
            if $self->return_type ne $return_type;
    }
    else {
        $self->return_type( $return_type );
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
