use Test::More tests => 1;

use MooseX::Declare;

TODO: {
    local $TODO = 'method is set up outside of classes and roles';
    eval 'method foo ($bar) { }';
    ok($@, 'method keyword not set up outside of classes');
}
