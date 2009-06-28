package LCore::Expression::Variable;
use Moose;

extends 'LCore::Expression';

has name => (is => "ro", isa => "Str");

__PACKAGE__->meta->make_immutable;
no Moose;
1;
