#!/usr/bin/perl -w

use Test::More tests => 1;
use LCore::Level1;
use Data::Dumper;
use LCore::Procedure;

my $l = LCore->new( env => LCore::Level1->new );

my $x = $l->analyze_it(q{
  (if (= n 1) 1
          (* n (factorial (- n 1))))
});

my $env = $l->env;
my $proc = LCore::Procedure->new( { env => $env,
                                    body => $x,
                                    parameters => ['n'] } );

$env->set_symbol('factorial', $proc);

$env->set_symbol('-' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] - $_[1];
                          }));
$env->set_symbol('*' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] * $_[1];
                          }));
$env->set_symbol('=' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] == $_[1];
                          }));

is($l->analyze_it(q{(factorial 5)})->($env), 120);
