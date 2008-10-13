use MooseX::Declare;

class Foo {
    has 'affe' => (
        is  => 'ro',
        isa => 'Str',
    );

    sub foo {}

    class Bar is mutable {
        sub bar {}
    }

    class Baz {
        sub baz {}
    }
}

role Role {
    requires 'required_thing';
    sub role_method {}
}

class Moo::Kooh {
    extends 'Foo';
    with 'Role';

    sub kooh {}
    sub required_thing {}
}

class Corge extends Foo::Bar with Role {
    sub corge {}
    sub required_thing {}
}

class Quux extends Corge {
    has 'x' => (
        is  => 'ro',
        isa => 'Int',
    );

    sub quux {}
}

1;
