use strict;
use warnings;
use Test::More tests => 1;

is system($^X, '-Ilib', '-c', 't/lib/WithNewline.pm') >> 8, 0,
    'should not throw an "expected option name" error';
