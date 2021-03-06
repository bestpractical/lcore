#!/usr/bin/perl -w

use Test::More tests => 8;
use LCore::Level2;
use LCore::Parameter;
use Data::Dumper;$Data::Dumper::Deparse=1;
use LCore::Procedure;
use Test::Exception;
my $l = LCore->new( env => LCore::Level2->new );

# compile time check
throws_ok {
    $l->analyze_it(q{(* n n)});
} qr/'\*' not defined/;

$l->env->set_symbol('*' => LCore::Primitive->new
                        ( body => sub {
                              return $_[0] * $_[1];
                          },
                          parameters => [ LCore::Parameter->new({ name => 'a', type => 'Num' }),
                                          LCore::Parameter->new({ name => 'b', type => 'Num' }) ],
                          return_type => 'Num',
                      ));

throws_ok {
    $l->analyze_it(q{(* 5 "str")});
} qr/type mismatch for '\*' parameters 2: expecting Num, got Str/;

throws_ok {
    my $proc = LCore::Procedure->new( { env => $l->env,
                                        body => $l->analyze_it(q{(* n n)}),
                                        parameters => ['n'],
                                        return_type => 'Str' } );
} qr/return type mismatch/;


my $proc = LCore::Procedure->new( { env => $l->env,
                                    body => $l->analyze_it(q{(* n n)}),
                                    parameters => ['n'] } );

is($proc->return_type, 'Num', "return type derived");

$l->env->set_symbol('hello' => LCore::Primitive->new
                        ( body => sub {
                              return 'hello',
                          },
                          parameters => [],
                          return_type => 'Str',
                      ));

throws_ok {
    $l->analyze_it(q{(* 5 (hello))});
} qr/type mismatch for '\*' parameters 2: expecting Num, got Str/;

throws_ok {
    $l->analyze_it(q{(* 5 (lambda (x) x))});
} qr/type mismatch for '\*' parameters 2: expecting Num, got Function/;

throws_ok {
    $l->analyze_it(q{(* 5 ((lambda (x) "hi") 9))});
} qr/type mismatch for '\*' parameters 2: expecting Num, got Str/;

TODO: {
    local $TODO = 'make lambda derive types from argument';

throws_ok {
    $l->analyze_it(q{(* 5 ((lambda (x) x) "hi"))});
} qr/type mismatch for '\*' parameters 2: expecting Num, got Str/;

};
