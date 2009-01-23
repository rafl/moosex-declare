#!/usr/bin/env perl

use Test::More tests => 1;
use MooseX::Declare;
class BreakingClass {
    method causes_bus_error ($key) {
        delete $self->hash_attrib($key);
   }
}
ok 1 => "should not crash";
