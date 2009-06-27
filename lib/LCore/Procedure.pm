package LCore::Procedure;
use Moose;

has env => (is => "ro", isa => "LCore::Env");
has body => (is => "ro", isa => "CodeRef");
has parameters => (is => "ro", isa => "ArrayRef");
has lazy => (is => "ro", isa => "Bool", default => sub { 1 });

BEGIN {
use overload (
        fallback => 1,
        '&{}' => sub { my $self = shift; sub { $self->apply(@_) } },
    );
}

sub apply {
    my ($self, @args) = @_;

    die "argument number mismatch" if $#{$self->parameters} ne $#args;
    my %args = map { $_ => shift @args } @{$self->parameters};
    return $self->body->($self->env->extend(\%args));
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
