use strict;
use warnings;
use inc::Module::Install;

name 'Moose-Declare';
all_from 'lib/Moose/Declare.pm';

requires 'Devel::Declare';
requires 'Moose';

WriteAll;
