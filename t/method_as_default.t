use Test::More;
use MooseX::Declare;

class Foo {
    has bar => (
        is      => 'ro',
        default => method { ref $self },
    );
}

is(Foo->new->bar,'Foo','yay');

done_testing;
