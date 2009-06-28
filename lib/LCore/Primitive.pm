package LCore::Primitive;
use Moose;

has body => (is => "ro", isa => "CodeRef");

has parameters => (is => "ro", isa => "ArrayRef[LCore::Parameter]");

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
