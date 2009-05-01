use MooseX::Declare;
use Test::More tests => 3;

class Foo {
    use Carp 'croak';
}

class Bar is dirty {
    use Carp 'croak';
}

class Baz is clean {
    use Carp 'croak';
}

ok(!Foo->can('croak'), '... Foo is clean');
ok( Bar->can('croak'), '... Bar is dirty');
ok(!Baz->can('croak'), '... Foo is clean');
