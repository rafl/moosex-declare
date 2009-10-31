use strict;
use warnings;
use inc::Module::Install;

name 'MooseX-Declare';
all_from 'lib/MooseX/Declare.pm';

requires 'Devel::Declare' => '0.005011';
requires 'namespace::clean' => '0.11';
requires 'namespace::autoclean' => '0.09';
requires 'Moose' => '0.90';
requires 'MooseX::Method::Signatures' => '0.24';
requires 'MooseX::Role::Parameterized' => '0.12';
requires 'MooseX::Types' => '0.20'; # need MooseX::Types::Moose
requires 'List::MoreUtils';

test_requires 'Test::Exception';
test_requires 'Test::NoWarnings';
tests_recursive;

makemaker_args(dist => { PREOP => 'pod2text lib/MooseX/Declare.pm > README' });

repository('git://github.com/rafl/moosex-declare.git');
bugtracker 'http://rt.cpan.org/Public/Dist/Display.html?Name=MooseX-Declare';

WriteAll;
