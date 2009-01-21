use strict;
use warnings;

use Test::More tests => 1;
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
}
my $vh;

lives_ok {
    $vh = ValueHolder->new(value => 22);
    $vh->value();
}
