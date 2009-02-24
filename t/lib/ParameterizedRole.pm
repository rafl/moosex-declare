use MooseX::Declare;

role Counter (Str $name) {
    has $name => (is => 'rw', isa => 'Int', default => 0);

    method "increment_${name}" {
        $self->$name($self->$name + 1);
    }

    method "decrement_${name}" {
        $self->$name($self->$name - 1);
    }
}

1;
