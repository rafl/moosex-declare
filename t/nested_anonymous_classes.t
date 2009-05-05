use strict;
use warnings;
use Test::More tests => 2;
use Test::Exception;

use MooseX::Declare;

my $stuff = <<'CLASS';
use MooseX::Declare;
role Bar
{
    sub baz { print "Bar::baz called\n"; }
}

class Foo with Bar
{
    sub anon
    {
        my $class2 = class with Bar { sub yarp { print "anon yarp called\n" } };
    }
}
CLASS

lives_ok(sub {
    eval $stuff;
    die $@ if $@;
}, 'Compiled nested anonymous composed class successfully');

my $stuff2 = <<'CLASS2';
use MooseX::Declare;
class Baz
{
    sub foo
    {
        class Gorch
        {
            sub blat { print "blat\n"; }
        }

        my $named = Gorch->new();
        $named->blat();
    }
}

my $baz = Baz->new();
$baz->foo();
CLASS2

lives_ok(sub {
    eval $stuff2;
    die $@ if $@;
}, 'Nested named declaration and execution outside of declaration scope works');
