package LCore::Env;
use Moose;
use MooseX::AttributeHelpers;

has parent => (is => "ro", isa => "LCore::Env");

has symbols => (
    metaclass => 'Collection::Hash',
    is => "ro",
    isa => "HashRef",
    default => sub { {} },
    provides  => {
        'set'    => 'set_symbol',
        'get'    => 'get_symbol',
        'exists' => 'has_symbol',
    },
);

sub get_value {
    my $self = shift;
    my $name = shift;
    my $env = $self;
    while ($env) {
        return $env->get_symbol($name) if $env->has_symbol($name);
        $env = $env->parent;
    }
}

sub extend {
    my $self = shift;
    my $vars = shift;
    return __PACKAGE__->new( symbols => { %$vars }, parent => $self );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

