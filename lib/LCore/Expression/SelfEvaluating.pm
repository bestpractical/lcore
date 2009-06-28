package LCore::Expression::SelfEvaluating;
use Moose;

extends 'LCore::Expression';

has value => (is => "ro", isa => "Str");

__PACKAGE__->meta->make_immutable;
no Moose;
1;
