package LCore::Procedure;
use Moose;

has env => (is => "ro", isa => "LCore::Env");
has body => (is => "ro", isa => "CodeRef|LCore::Expression");
has parameters => (is => "ro", isa => "ArrayRef");
has return_type => (is => "rw", isa => "Str");
has lazy => (is => "ro", isa => "Bool", default => sub { 1 });

use overload (
    fallback => 1,
    '&{}' => sub { my $self = shift; sub { $self->apply(@_) } },
);

sub BUILD {
    my ($self, $params) = @_;
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
