package LCore::Function;
use Moose::Role;
use Moose::Util::TypeConstraints;

type 'Function';

subtype 'LCore::Type'
    => as 'Object'
    => where { $_->isa('Moose::Meta::TypeConstraint') };

coerce 'LCore::Type'
    => from 'Str'
    => via { Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( $_ ) };

has parameters => (is => "ro", isa => "ArrayRef");
has return_type => (is => "rw", isa => "LCore::Type", coerce => 1);
has lazy => (is => "ro", isa => "Bool", default => 1);
has slurpy => (is => "ro", isa => "Bool", default => 0);

requires 'apply';

no Moose;
1;
