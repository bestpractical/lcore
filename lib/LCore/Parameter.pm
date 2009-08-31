package LCore::Parameter;
use Moose;
use Moose::Util::TypeConstraints qw(find_type_constraint type);

type 'Function';

has name => (is => "ro", isa => "Str");
has type => (is => "ro", isa => "Moose::Meta::TypeConstraint");

sub BUILDARGS {
    my ($self, $args) = @_;
    if ($args->{type} && !ref($args->{type})) {
        $args->{type} = Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($args->{type})
    }
    return $args;
}

use overload (
    fallback => 1,
    '""' => sub { my $self = shift; $self->name },
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;
