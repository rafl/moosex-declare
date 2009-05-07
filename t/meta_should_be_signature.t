use 5.010;
use MooseX::Declare;

use Test::More('tests', 1);

class Foo
{
    method blat ( Str $str1 )
    {
        say $str1;
    }
}

my $foo = Foo->new();

my $blat = $foo->meta->get_method('blat');

isa_ok($blat, 'MooseX::Method::Signatures::Meta::Method');
