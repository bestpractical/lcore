#!/usr/bin/perl -w

use Test::More tests => 4;
use LCore::Level2;
use LCore::Parameter;
use LCore::Procedure;
use Test::Exception;
my $l = LCore->new( env => LCore::Level2->new );

$l->env->set_symbol($_ => LCore::Primitive->new
                        ( body => sub {
                              die 'stub only';
                          },
                          parameters => [ LCore::Parameter->new({ name => 'a', type => 'Str' }),
                                          LCore::Parameter->new({ name => 'b', type => 'Str' }) ],
                          return_type => 'Bool',
                      ))
    for qw( str.is str.!is str.contains str.!contains str.startswith str.endswith );

$l->env->set_symbol($_ => LCore::Primitive->new
                        ( body => sub {
                              die 'stub only';
                          },
                          parameters => [ LCore::Parameter->new({ name => 'a', type => 'Str' }),
                                          LCore::Parameter->new({ name => 'b', type => 'Num' }) ],
                          return_type => 'Bool',
                      ))
    for qw( str.isnum );

is_deeply( [sort keys %{ $l->env->find_functions_by_type(['Str'], 'Bool') }],
           [qw(str.!contains str.!is str.contains str.endswith str.is str.isnum str.startswith)] );

is_deeply( [sort keys %{ $l->env->find_functions_by_type('Str', 'Bool') }],
           [qw(str.!contains str.!is str.contains str.endswith str.is str.isnum str.startswith)] );

is_deeply( [sort keys %{ $l->env->find_functions_by_type(['Bool'], 'Bool')}],
            [qw(not)] );

is_deeply( [sort keys %{ $l->env->find_functions_by_type('Bool', 'Bool')}],
            [qw(and not or)] );

