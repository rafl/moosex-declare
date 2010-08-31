use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use Test::Compile';
    plan skip_all => 'Test::Compile required' if $@;
}

pm_file_ok('t/lib/WithNewline.pm', 'should not throw an "expected option name" error and segfault');

done_testing;
