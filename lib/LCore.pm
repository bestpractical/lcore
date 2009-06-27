package LCore;
use Moose;

use LCore::Env;
use LCore::Thunk;
use Data::SExpression qw(cons consp);
use UNIVERSAL::isa;
my $global_env = LCore::Env->new();

my $ds = Data::SExpression->new({use_symbol_class=>1,
                                 fold_lists => 1,
                                 fold_alists => 1,
                             });

has env => (
    is => "ro",
    isa => "LCore::Env",
    default => sub { $global_env },
    handles => ['analyze'],
);

sub global_env { $global_env };

sub analyze_it {
    my ($self, $expression_string) = @_;

    my $exp = $ds->read($expression_string);
    return $self->analyze($exp);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

