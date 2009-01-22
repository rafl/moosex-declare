#!/usr/bin/env perl

use MooseX::Declare;

class ValueClass {
}

class BreakingClass {
    method causes_segfault () {
        delete $self->hash_attrib('key');
   }
}
