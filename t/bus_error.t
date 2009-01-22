#!/usr/bin/env perl

use MooseX::Declare;

class ValueClass {
}

class BreakingClass {
    method causes_bus_error ($key) {
        delete $self->hash_attrib($key);
   }
}
