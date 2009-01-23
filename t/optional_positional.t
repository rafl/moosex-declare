use strict;
use warnings;

use Test::More tests => 2;
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

TODO: {
    local $TODO = 'buggy optional positionals';

    lives_ok {
        ValueHolder->new(value => 22)->value;
    } 'value() should not die';

    lives_and {
        is(ValueHolder->new->method1, 1, 'method1() should only get 1 element in @_');
    } 'nor should method1()';
}
