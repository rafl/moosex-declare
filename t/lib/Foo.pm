use MooseX::Declare;

class Foo {
    has 'affe' => (
        is  => 'ro',
        isa => 'Str',
    );

    method foo ($x) { $x }

    method inner { 23 }

    method bar ($moo) { "outer(${moo})-" . inner() }

    class Bar is mutable {
        method bar { blessed($_[0]) ? 0 : 1 }
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

    augment bar ($moo) { "inner(${moo})" }

    method kooh {}
    method required_thing {}
}

class Corge extends Foo::Bar with Role {
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

1;
