package LCore::Expression::SelfEvaluating;
use Moose;

extends 'LCore::Expression';

has value => (is => "ro", isa => "Str");

sub to_hash {
    my ($self) = shift;
    return { type => 'self_evaluating',
             value => $self->value,
         };
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
