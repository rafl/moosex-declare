use strict;
use warnings;
use Test::More;

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
