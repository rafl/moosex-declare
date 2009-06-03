use Test::More;
use MooseX::Declare;

class Foo {
    method foo (Foo $foo: Int $x) {
        $x - 5;
    }
}

class Bar extends Foo {
    around foo (Bar $bar: Int $x) {
        $orig->($bar, $x * 2);
    }
}

is(Bar->new->foo(10), 15, 'Test advice on class method');

done_testing;
