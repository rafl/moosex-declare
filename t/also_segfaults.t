#!/usr/bin/env perl

use Test::More tests => 1;
use MooseX::Declare;
class BreakingClass is mutable {
    method causes_segfault () {
        delete $self->hash_attrib('key');
   }
}
ok 1 => "It's alive!";
