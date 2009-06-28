package LCore::Expression::Application;
use Moose;

extends 'LCore::Expression';

has operator => (is => "ro", isa => "LCore::Expression");

has operands => (is => "ro", isa => "ArrayRef[LCore::Expression]");

__PACKAGE__->meta->make_immutable;
no Moose;
1;
