use strict;
use warnings;
use inc::Module::Install;

name 'MooseX-Declare';
all_from 'lib/MooseX/Declare.pm';

requires 'Devel::Declare';
requires 'B::Hooks::EndOfScope';
requires 'namespace::clean';
requires 'Moose';
requires 'MooseX::Method::Signatures' => '0.06';

tests_recursive;

WriteAll;
