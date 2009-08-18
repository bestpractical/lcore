package LCore::Function;
use Moose::Role;

has parameters => (is => "ro", isa => "ArrayRef");
has return_type => (is => "rw", isa => "Str");
has lazy => (is => "ro", isa => "Bool", default => 1);
has slurpy => (is => "ro", isa => "Bool", default => 0);

requires 'apply';

no Moose;
1;
