use Test::More tests => 1;
use MooseX::Declare;


my $foo = method () { "test" };

ok( $foo->(), "anony method works" );
