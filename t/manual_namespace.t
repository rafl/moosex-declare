#!/usr/bin/env perl
use strict;
use warnings;

use MooseX::Declare;
use Test::More tests => 5;

namespace Foo::Bar;

sub base { __PACKAGE__ }

class ::Baz {
    sub TestPackage::baz { __PACKAGE__ }
}

role ::Fnording {
    sub TestPackage::fnord { __PACKAGE__ }
}

class ::Qux extends ::Baz with ::Fnording {
    sub TestPackage::qux { __PACKAGE__ }
}

is( base(), 'main', 'namespace does not affect package' );
is( TestPackage->baz, 'Foo::Bar::Baz', 'relative namespace works' );
is( TestPackage->qux, 'Foo::Bar::Qux', 'relative superclass works' );
is( TestPackage->fnord, 'Foo::Bar::Fnording', 'relative namespace works in role' );
ok( Foo::Bar::Qux->does('Foo::Bar::Fnording'), 'relative role namespaces work' );

