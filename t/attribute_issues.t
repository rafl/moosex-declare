use Test::More tests => 2;
use Test::Warn;
use MooseX::Declare;

class UnderTest {
    method pass_through (:$param?) {
        $param;
    }
}

warnings_are {
    is(UnderTest->new->pass_through("send reinforcements, we're going to advance")
         => "send reinforcements, we're going to advance",
         "send three and fourpence, we're going to a dance");
} [], "silence is golden";
