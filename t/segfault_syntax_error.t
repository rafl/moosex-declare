use strict;
use warnings;
use Test::More tests => 1;

use MooseX::Declare;

class BreakingClass {
    method causes_bus_error {
        delete my $foo;
   }
}

pass('should not crash');
