use strict;
use warnings;
use inc::Module::Install;

name 'MooseX-Declare';
all_from 'lib/MooseX/Declare.pm';

requires 'Devel::Declare';
requires 'Scope::Guard';
requires 'namespace::clean';
requires 'Moose';
requires 'MooseX::Method::Signatures' => '0.06';

WriteAll;
