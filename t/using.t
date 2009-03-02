use MooseX::Declare;
use Test::More tests => 4;
use Test::Exception;

class Foo {
    using Carp qw/croak/;
    using MooseX::Types::Moose qw/Str/;
    using MooseX::Types::Structured qw/Tuple/;

    method fail ($class:) { croak 'korv' }
    method Tuple ($class:) { return Tuple[Str, Str] }
}

ok(!Foo->can('croak'));
ok( Foo->can('Tuple'));

is(Foo->Tuple->name, 'MooseX::Types::Structured::Tuple[Str,Str]');

throws_ok(sub {
    Foo->fail;
}, qr/\bkorv\b/);
