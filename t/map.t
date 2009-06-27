#!/usr/bin/perl -w

use Test::More tests => 1;
use LCore::Level1;
use Data::Dumper;
use LCore::Procedure;

my $l = LCore->new( env => LCore::Level1->new );

my $x = $l->analyze_it(q{(* n n)});

my $proc = LCore::Procedure->new( { env => $l->env,
                                    body => $x,
                                    parameters => ['n'] } );

$l->env->set_symbol('square', $proc);
$l->env->set_symbol('*' => bless sub {
                        return $_[0] * $_[1];
                    }, 'LCore::Primitive' );

is_deeply($l->analyze_it(q{(map square (list 5 (* 1 6) 7))})->($l->env), [25, 36, 49]);
