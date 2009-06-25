use strict;
use warnings;
use inc::Module::Install;

name 'MooseX-Declare';
all_from 'lib/MooseX/Declare.pm';

requires 'Devel::Declare' => '0.005001';
requires 'B::Hooks::EndOfScope';
requires 'namespace::clean';
requires 'namespace::autoclean' => '0.05';
requires 'Moose' => '0.82';
requires 'MooseX::Method::Signatures' => '0.16';

test_requires 'Test::Exception';
test_requires 'Test::NoWarnings';
tests_recursive;

makemaker_args(dist => { PREOP => 'pod2text lib/MooseX/Declare.pm > README' });

WriteAll;
