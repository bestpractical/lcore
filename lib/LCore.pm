package LCore;
use Moose;

use 5.008;
our $VERSION = '0.01';

use LCore::Env;
use LCore::Thunk;
use LCore::Exception;
use Data::SExpression qw(cons consp);
use UNIVERSAL::isa;

=head1 NAME

LCore - An embedded lisp in pure perl

=cut


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

=head1 AUTHOR

CL Kao <clkao@bestpractical.com>

=head1 LICENSE

Copyright 2009 Best Practical Solutions, LLC

This module may be distributed under the same terms as Perl itself.

=cut


1;

