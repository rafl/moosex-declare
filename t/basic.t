use strict;
use warnings;
use Test::More tests => 8;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok('Foo'); }

{
    my $pkg = 'Foo';
    ok($pkg->can('foo'));
}

{
    my $pkg = 'Foo::Bar';
    ok($pkg->can('bar'));
}

{
    my $pkg = 'Role';
    ok($pkg->meta->isa('Moose::Meta::Role'));
    ok($pkg->can('role_method'));
}

{
    my $pkg = 'Moo::Kooh';
    ok($pkg->isa('Foo'));
    ok($pkg->can('kooh'));
    ok($pkg->does('Role'));
}
