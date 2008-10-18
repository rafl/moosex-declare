use MooseX::Declare;

class Foo {
    has 'affe' => (
        is  => 'ro',
        isa => 'Str',
    );

    method foo ($x) { $x }

    class Bar is mutable {
        method bar {}
    }

    class Baz {
        method baz {}
    }
}

role Role {
    requires 'required_thing';
    method role_method {}
}

class Moo::Kooh {
    extends 'Foo';
    with 'Role';

    around foo ($x) { $x + 1 }

    method kooh {}
    sub required_thing {}
}

class Corge extends Foo::Bar with Role {
    method corge {}
    sub required_thing {}
}

class Quux extends Corge {
    has 'x' => (
        is  => 'ro',
        isa => 'Int',
    );

    method quux {}
}

1;
