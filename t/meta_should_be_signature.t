use Test::More tests => 1;
use MooseX::Declare;

class Foo {
    method blat (Str $str) { }
}

my $foo = Foo->new();

my $blat = $foo->meta->get_method('blat');

isa_ok($blat, 'MooseX::Method::Signatures::Meta::Method');
