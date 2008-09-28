use MooseX::DefClass;

=for later
class Foo {
    sub foo {}

    class Bar {
        sub bar {}
    }

    class Baz {
        sub baz {}
    }
}

role Role {
    requires 'required_thing';
    sub role {}
}
=cut

class Moo::Kooh {
    extends 'Foo';
    with 'Role';

    sub kooh {}
    sub required_thing {}
}

=for later
class Corge extends Foo::Bar with Role {
    sub corge {}
    sub required_thing {}
}

class Quux extends Corge is immutable {
    sub quux {}
}
=cut

1;
