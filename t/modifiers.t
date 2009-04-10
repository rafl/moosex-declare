#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use MooseX::Declare;

my @log = ();
BEGIN { $SIG{__WARN__} = sub { push @log, \@_ } };

role Bar {
  use Moose::Role;

  before do_foo {
    push @log, { before => 'string' };
  }
}

class Foo with Bar {
  method do_foo { 
    push @log, { class => 'string' };
  }
}

Foo->new->do_foo;

is_deeply(\@log, [{'before', 'string'}, {'class','string'}] );
