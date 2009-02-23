use Test::More tests => 6;
use Test::Warn;
use Test::Exception;
use MooseX::Declare;

class UnderTest {
    method pass_through (:$param?) {
        $param;
    }

    method pass_through2 (:name($value)?) {
        $value;
    }

    method pass_through3 ($value?) {
        $value || 'default';
    }
}

warnings_are {
    is(UnderTest->new->pass_through(param => "send reinforcements, we're going to advance")
       => "send reinforcements, we're going to advance",
       "send three and fourpence, we're going to a dance");
} [], "silence is golden";

lives_ok {
    is(UnderTest->new->pass_through2(name => "foo")
       => "foo",
       "should be 'foo'");
} 'name => $value';

lives_ok {
    is(UnderTest->new->pass_through3()
       => "default",
       "should be 'default'");
} 'optional param';
