#!/usr/bin/perl -w

use Test::More tests => 1;
use LCore::Level1;
use Data::Dumper;
use LCore::Procedure;

my $l = LCore->new( env => LCore::Level1->new );
$l->env->set_symbol('*' => bless sub {
                        return $_[0] * $_[1];
                    }, 'LCore::Primitive' );

is_deeply($l->analyze_it(q{((lambda (x) (* x x)) 42))})->($l->env), 1764);
