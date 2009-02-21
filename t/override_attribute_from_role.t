use Test::More tests => 1;
use Test::Exception;

use MooseX::Declare;

role ProvidesFooAttribute {
    has foo => ( is => 'ro' );
}

TODO: {
    local $TODO = 'Fails';
    lives_ok {
        class Consumer with ProvidesFooAttribute {
            has '+foo' => ( isa => 'Int' );
        }
    } 'Delayed role application does not play nice with has +foo';
}
