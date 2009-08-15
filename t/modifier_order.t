use MooseX::Declare;
use Test::More('tests', 1);

namespace Foo;

role ::Z {
    method foo (Int $x) { $x }
}

role ::C {
    with '::Z';
    around foo (Int $x) { $orig->($self, int($x / 3)) }
}

role ::B {
    with '::C';
    around foo (Int $x) { $orig->($self, $x + 2) }
}

role ::A {
    with '::B';
    around foo (Int $x) { $orig->($self, $x * 2) }
}

class TEST {
    with '::A';
    around foo (Int $x) { $orig->($self, $x + 2) }
}

is(TEST->new()->foo(12), 10, 'Method modifier and roles ordering');

1;
