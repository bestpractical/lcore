package LCore::Expression;
use Moose;

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
