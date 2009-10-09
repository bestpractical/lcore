package LCore::Parameter;
use Moose;

has name => (is => "ro", isa => "Str");
has type => (is => "ro", isa => "LCore::Type", coerce => 1);

use overload (
    fallback => 1,
    '""' => sub { my $self = shift; $self->name },
);

sub to_hash {
    my ($self) = shift;
    return { name => $self->name, type => $self->type };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
