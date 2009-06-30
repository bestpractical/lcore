package LCore::Expression;
use Moose;

=head1 NAME

LCore::Expression - expression type class

=head1 SYNOPSIS



=head1 DESCRIPTION

An expression type is a class that contains the information about:

=over

=item *

S-Expression to recognize

=item *

Properties of the expression.  for example, an application expression
would store its operator and operands (in the form of
LCore::Expression) for introspection.  A lambda expression would have
the arguments and body.  (Note that lambda expression is not yet
refactored into LCore::Expression.)

=item *

actual code to run on evaluation.  C<code> is a closure that takes an
L<LCore::Env> object.

=item *

(not yet) method to reconstruct the S-Expression tree

=back

Currently the actual analyze function constructing the expressions are
in L<LCore::Env>, because there can be different versions of
analyzing, such as plain application expression in level1, and with
type annotation in some higher level.  But this should be cleaned up
somehow, perhaps class traits for composing expression with additional
features.

=cut

has code => (is => "ro", isa => "CodeRef");

BEGIN {
use overload (
        fallback => 1,
        '&{}' => sub { my $self = shift; sub { $self->execute(@_) } },
    );
}

sub execute {
    my $self = shift;
    $self->code->(@_);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

