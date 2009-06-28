package LCore::Parameter;
use Moose;

has name => (is => "ro", isa => "Str");
has type => (is => "ro", isa => "Str");

use overload (
    fallback => 1,
    '""' => sub { my $self = shift; $self->name },
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;
