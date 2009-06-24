package LCore::Procedure;
use Moose;

has env => (is => "ro", isa => "LCore::Env");
has body => (is => "ro", isa => "CodeRef");
has parameters => (is => "ro", isa => "ArrayRef");

use overload '&{}' => \&execute;

sub execute {
    my $self = shift;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
