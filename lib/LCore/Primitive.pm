package LCore::Primitive;
use Moose;
use LCore::Exception;

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
    my $ret = eval { $self->body->(@_) };
    my $e;
    if ( $e = LCore::Exception->caught() ) {
        $e->rethrow;
    }
    elsif ( $e = Exception::Class->caught() ) {
        LCore::Exception::Runtime->throw( message => $@ );
    }
    return $ret;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
