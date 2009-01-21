use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use MooseX::Declare;

class ValueHolder {
    has value => (
        is => 'rw',
        isa => 'Any',
    );

    around value ($newval?) {
        $orig->($newval);
    }

    method method1 ($argument?) {
        +@_;
    }
}
my $vh;

lives_ok {
    $vh = ValueHolder->new(value => 22);
    $vh->value();
} 'value() should not die';

SKIP: {
    lives_ok {
        $vh = ValueHolder->new;
        is $vh->method1 => 1, 'method1() should only get 1 element in @_';
    } 'nor should method1()';

    skip 'method1() threw an exception', 1 if $@;
}
