#!/usr/bin/perl -w
use Test::More tests => 5;
use LCore::Level2;
use LCore::Parameter;
use Data::Dumper;$Data::Dumper::Deparse=1;
use LCore::Procedure;
use Test::Exception;
my $l = LCore->new( env => LCore::Level2->new );
$l->env->set_symbol('*' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] * $_[1];
                          },
                          parameters => [ LCore::Parameter->new({ name => 'a', type => 'Num' }),
                                          LCore::Parameter->new({ name => 'b', type => 'Num' }) ],
                          return_type => 'Num',
                      ));

my $proc = LCore::Procedure->new( { env => $l->env,
                                    body => $l->analyze_it(q{(* n n)}),
                                    parameters => [LCore::Parameter->new({ name => 'n', type => 'Num' } )] } );

is($proc->return_type, 'Num', "return type derived");

$l->env->set_symbol('square' => $proc);

my $proc2 = LCore::Procedure->new( { env => $l->env,
                                     body => $l->analyze_it(q{(map square (list 5 (* 1 6) 7))}),
                                     parameters => [] } );

like $proc2->return_type, qr/^ArrayRef/;

is_deeply($proc2->apply(), [25, 36, 49]);

is_deeply($l->analyze_it(q{(map square 5 6 7))})->($l->env), [25, 36, 49]);

is_deeply($l->analyze_it(q{(map square 5))})->($l->env), [25]);
