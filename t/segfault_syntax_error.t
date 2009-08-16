use strict;
use warnings;
use Test::More;

BEGIN {
    plan skip_all => '5.10.1 required for this test, due to a perl bug'
        if $] < 5.010001;
}

use MooseX::Declare;

eval q[
    class BreakingClass {
        method causes_bus_error {
            delete my $foo;
        }
    }
];

pass('should not crash');

done_testing;
