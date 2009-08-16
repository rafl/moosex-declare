use MooseX::Declare;

role Counter (Str :$name) {
    has $name => (is => 'rw', isa => 'Int', default => 0);

    method "increment_${name}" {
        $self->$name($self->$name + 1);
    }

    method "reset_${name}" {
        $self->$name(0);
    }
}

class MyGame::Weapon {
    with Counter => { name => 'enchantment' };
}

class MyGame::Wand {
    with Counter => { name => 'zapped' };
}

1;
