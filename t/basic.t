use strict;
use warnings;
use Test::More tests => 17;
use Test::Moose;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok('Foo'); }

{
    my $pkg = 'Foo';
    meta_ok($pkg);
    has_attribute_ok($pkg, 'affe');
    can_ok($pkg, 'affe');
    can_ok($pkg, 'foo');
    ok(!$pkg->can('has'));
    ok(!$pkg->can('inner'));
    ok($pkg->meta->is_immutable);
}

{
    my $pkg = 'Foo::Bar';
    meta_ok($pkg);
    can_ok($pkg, 'bar');
    ok(!$pkg->meta->is_immutable);
}

{
    my $pkg = 'Role';
    meta_ok($pkg);
    isa_ok($pkg->meta, 'Moose::Meta::Role');
    can_ok($pkg, 'role_method');
}

{
    my $pkg = 'Moo::Kooh';
    ok($pkg->isa('Foo'));
    can_ok($pkg, 'kooh');
    does_ok($pkg, 'Role');
}
