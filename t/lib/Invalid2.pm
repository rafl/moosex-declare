use MooseX::Declare;

class Foo {
    # more methods here

    method baz(Num $x where { $x > 0) {
        return 1;
    }
}
