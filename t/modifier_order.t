use MooseX::Declare;
use Test::More;

namespace Foo;

role ::Z {
    method foo (Int $x) { $x }
}

role ::C {
    with '::Z';
    around foo (Int $x) { $self->$orig(int($x / 3)) }
}

role ::B {
    with '::C';
    around foo (Int $x) { $self->$orig($x + 2) }
}

role ::A {
    with '::B';
    around foo (Int $x) { $self->$orig($x * 2) }
}

class TEST {
    with '::A';
    around foo (Int $x) { $self->$orig($x + 2) }
}

is(TEST->new()->foo(12), 10, 'Method modifier and roles ordering');

class AnotherTest {
    with '::Z';
    around foo (Int $x) { $self->$orig($x * 2) }
}

is(AnotherTest->new->foo(21), 42,
   'modifiers also work when applying directly to an actual method compose from a role');

done_testing;

1;
