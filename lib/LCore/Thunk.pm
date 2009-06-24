package LCore::Thunk;
use Moose;

has env => (is => "ro", isa => "LCore::Env");

has is_evaluated => (is => "rw", isa => "Bool");

has evaluated_result => (is => "rw");

has delayed => (is => "ro", isa => "CodeRef");

use overload '&{}' => \&execute;

sub execute {
    my ($self) = @_;
    unless ($self->is_evaluated) {
        $self->evaluated_result( $self->delayed->($self->env) );
        $self->is_evaluated(1);
    }
    return sub { $self->evaluated_result }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
