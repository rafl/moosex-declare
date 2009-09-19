use Test::More;
use MooseX::Declare;

role TestRole (Str :$foo = 'bar') {
    method foo (ArrayRef $x) { $x }
    method bar (Str      $x) { $x }
}

class TestClass {
    with TestRole => { foo => 'bar' };
}

my $x = TestClass->new;
isa_ok($x, 'TestClass');
is_deeply($x->foo([]), []);
is($x->bar('baz'), 'baz');

done_testing;
