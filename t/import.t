use Test::More tests => 1;
use MooseX::Declare;

eval '$foo = 42';
ok($@, 'MooseX::Declare imports strict');
