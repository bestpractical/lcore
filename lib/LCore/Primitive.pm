package LCore::Primitive;
use Moose;

=head1 NAME

LCore::Primitive - primitive functions

=head1 SYNOPSIS



=head1 DESCRIPTION

This class represents primitive functions, whre C<body> contains the
native perl code.  This is pretty much the same as
L<LCore::Procedure>, and should probably have the duplicated
attributes refactored into Applicable role.

=cut

has body => (is => "ro", isa => "CodeRef");

has parameters =>  (is => "ro", isa => "ArrayRef[LCore::Parameter]");
has return_type => (is => "ro", isa => "Str");

has lazy => (is => "ro", isa => "Bool", default => sub { 1 });


BEGIN {
use overload (
        fallback => 1,
        '&{}' => sub { my $self = shift; sub { $self->apply(@_) } },
    );
}

sub apply {
    my $self = shift;
    goto $self->body;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
