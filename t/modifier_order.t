use MooseX::Declare;
use Test::More('tests', 1);

role Foo::Z {
    method foo (Int $x) { $x }
}

role Foo::C {
    with 'Foo::Z';
    around foo (Int $x) { $orig->($self, int($x / 3)) }
}

role Foo::B {
    with 'Foo::C';
    around foo (Int $x) { $orig->($self, $x + 2) }
}

role Foo::A {
    with 'Foo::B';
    around foo (Int $x) { $orig->($self, $x * 2) }
}

class TEST {
    with 'Foo::A';
    around foo (Int $x) { $orig->($self, $x + 2) }
}

is(TEST->new()->foo(12), 10, 'Method modifier and roles ordering');

1;
