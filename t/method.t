use Test::More tests => 1;
use MooseX::Declare;

class Foo { 
    has 'bar' => ( 
        is => 'ro', 
        default => method () { 
            my $self = shift;             
            ref($self); 
        }
    );
}



is(Foo->new->bar,'Foo','yay');
