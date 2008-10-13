use strict;
use warnings;
use Test::More tests => 3;
use Test::Moose;

use Moose::Declare;

my $class = class {
    has 'foo' => (
        is  => 'ro',
        isa => 'Str',
    );
};

meta_ok($class);
can_ok($class, 'new');
has_attribute_ok($class, 'foo');
