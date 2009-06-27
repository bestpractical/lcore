#!/usr/bin/perl -w

use Test::More tests => 1;
use LCore::Level1;
use Data::Dumper;
use LCore::Procedure;

my $x = LCore->analyze_it(q{(* n n)});

my $env = LCore::Level1->new;
my $proc = LCore::Procedure->new( { env => $env,
                                    body => $x,
                                    parameters => ['n'] } );

$env->set_symbol('square', $proc);
$env->set_symbol('*' => bless sub {
                     return $_[0] * $_[1];
                 }, 'LCore::Primitive' );

is_deeply(LCore->analyze_it(q{(map square (list 5 (* 1 6) 7))})->($env), [25, 36, 49]);
