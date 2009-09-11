use MooseX::Declare;

class Foo {
    has 'affe' => (
        is  => 'ro',
        isa => 'Str',
    );

    method foo ($x) { $x }

    method inner { 23 }

    method bar ($moo) { "outer(${moo})-" . inner() }

    class ::Bar is mutable {
        method bar { blessed($_[0]) ? 0 : 1 }
    }

    class ::Baz {
        method baz {}
    }
}

role Role {
    requires 'required_thing';
    method role_method {}
}

class Moo::Kooh {
    extends 'Foo';

    around foo ($x) { $x + 1 }

    augment bar ($moo) { "inner(${moo})" }

    method kooh {}
    method required_thing {}

    with 'Role';
}

class Corge extends Foo::Baz with Role {
    method corge {}
    method required_thing {}
}

class Quux extends Corge {
    has 'x' => (
        is  => 'ro',
        isa => 'Int',
    );

    method quux {}
}

role SecondRole {}

class MultiRole with Role with SecondRole {
    method required_thing {}
}

class MultiRole2 with (Role, SecondRole) {
    method required_thing {}
}

1;
