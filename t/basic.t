use strict;
use warnings;
use Test::More tests => 24;
use Test::Moose;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok('Foo'); }

{
    my $pkg = 'Foo';
    meta_ok($pkg);
    has_attribute_ok($pkg, 'affe');
    can_ok($pkg, $_)
        for qw/affe foo inner/;
    ok(!$pkg->can($_))
        for qw/has method override/;
    ok($pkg->meta->is_immutable);

    my $o = $pkg->new;
    is($o->foo(42), 42);
    is($o->inner, 23);
}

{
    my $pkg = 'Foo::Bar';
    meta_ok($pkg);
    can_ok($pkg, 'bar');
    ok(!$pkg->meta->is_immutable);
    lives_ok(sub {
        $pkg->new->bar;
    });
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

    my $o = $pkg->new;
    is($o->foo(42), 43);
    is($o->bar(23), 'outer(23)-inner(23)');
}
