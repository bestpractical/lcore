package LCore::Expression::Variable;
use Moose;

extends 'LCore::Expression';

has name => (is => "ro", isa => "Str");

sub to_hash {
    my ($self) = shift;
    return { type => 'variable',
             name => $self->name,
         };
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
