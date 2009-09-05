use MooseX::Declare;

role Counter (Str :$name, Int :$charges = 1) {
    has $name => (is => 'rw', isa => 'Int', default => $charges);

    method "increment_${name}" {
        $self->$name($self->$name + 1);
    }

    method "reset_${name}" {
        $self->$name(0);
    }
}

class MyGame::Weapon {
    with Counter => { name => 'enchantment', charges => 5 };
}

class MyGame::Wand {
    with Counter => { name => 'zapped', charges => 3 };
}

class MyGame::Scroll {
    with Counter => { name => 'spelled' };
}

1;
