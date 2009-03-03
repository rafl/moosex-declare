use MooseX::Declare;
use Test::More tests => 2;

class Foo {
    use Carp 'croak';
}

class Bar is dirty {
    use Carp 'croak';
}

ok(!Foo->can('croak'), '... Foo is clean');
ok( Bar->can('croak'), '... Bar is dirty');
