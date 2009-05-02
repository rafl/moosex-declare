use Test::More tests => 1;

use MooseX::Declare;

eval 'method foo ($bar) { }';
ok($@, 'method keyword not set up outside of classes');
