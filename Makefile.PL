#!/usr/bin/env perl

use inc::Module::Install;

all_from('lib/LCore.pm');

test_requires(
    Test::More      => 0,
    Data::Dumper    => 0,
    Test::Exception => 0,
);

requires(
    Data::SExpression        => 0.41,
    Moose                    => 0,
    MooseX::Traits           => 0.06,
    MooseX::ClassAttribute   => 0,
    MooseX::AttributeHelpers => 0,
);


&WriteAll();
