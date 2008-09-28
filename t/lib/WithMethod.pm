use MooseX::DefClass;

class Foo {
    method foo {}

    class Bar {
        method bar {}
    }

    class Baz {
        method baz {}
    }
}

role Role {
    requires 'required_thing';
    method role {}
}

class Moo::Kooh {
    extends 'Foo';
    with 'Role';

    method kooh {}
    method required_thing {}
}

class Corge extends Foo::Bar with Role {
    method corge {}
    method required_thing {}
}

class Quux extends Corge is immutable {
    method quux {}
}

1;
