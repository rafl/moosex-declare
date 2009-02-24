use strict;
use warnings;
use inc::Module::Install;

name 'MooseX-Declare';
all_from 'lib/MooseX/Declare.pm';

requires 'Devel::Declare' => '0.003000';
requires 'B::Hooks::EndOfScope';
requires 'namespace::clean';
requires 'Moose';
requires 'MooseX::Method::Signatures' => '0.09';

test_requires 'Test::Exception';
test_requires 'Test::NoWarnings';
tests_recursive;

makemaker_args(dist => { PREOP => 'pod2text lib/MooseX/Declare.pm > README' });

WriteAll;
