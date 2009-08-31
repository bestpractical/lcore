#!/usr/bin/perl -w
use Test::More tests => 2;
use LCore::Level2;
use LCore::Procedure;

my $l = LCore->new( env => LCore::Level2->new );
my $env = $l->env;
$env->set_symbol('Str.Eq' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] eq $_[1];
                          },
                          parameters => [ LCore::Parameter->new({ name => 'left', type => 'Str' }),
                                          LCore::Parameter->new({ name => 'right', type => 'Str' })],
                          return_type => 'Bool'
                      ));

$env->set_symbol('bar' => LCore::Primitive->new
                       ( body => sub { 'foo' },
                         return_type => 'Str' ));


is($l->analyze_it(q{(Str.Eq "foo" (bar))})->($env), 1);

is($l->analyze_it(q{(Str.Eq "foo" "1")})->($env), '');


$env->set_symbol('Str.Eq' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] eq $_[1];
                          },
                          parameters => [ LCore::Parameter->new({ name => 'left', type => 'Str' }),
                                          LCore::Parameter->new({ name => 'right', type => 'Str' })],
                          return_type => 'Bool'
                      ));
