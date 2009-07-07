package LCore::Primitive;
use Moose;

with 'LCore::Function';

=head1 NAME

LCore::Primitive - primitive functions

=head1 SYNOPSIS



=head1 DESCRIPTION

This class represents primitive functions, whre C<body> contains the
native perl code.

=cut

has body => (is => "ro", isa => "CodeRef");

sub apply {
    my $self = shift;
    goto $self->body;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
