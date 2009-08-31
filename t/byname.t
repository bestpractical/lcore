#!/usr/bin/perl -w

use Test::More tests => 3;
use LCore::Level1;
use Data::Dumper;
use LCore::Procedure;

my $l = LCore->new( env => LCore::Level1->new );
$l->env->set_symbol('/' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] / $_[1];
                          },
                          parameters => [ map { LCore::Parameter->new({ name => $_, type => 'Num' }) } ('x', 'y') ],
                      ));

is_deeply($l->analyze_it(q{(/ 5 2)})->($l->env), 2.5);

is_deeply($l->analyze_it(q{(/ ((x . 5) (y . 2)))})->($l->env), 2.5);

is_deeply($l->analyze_it(q{(/ ((y . 5) (x . 2)))})->($l->env), 0.4);

