use strict;
use warnings;
use inc::Module::Install;

name 'MooseX-Declare';
all_from 'lib/MooseX/Declare.pm';

requires 'Devel::Declare';
requires 'Scope::Guard';
requires 'Moose';
requires 'namespace::clean';

WriteAll;
