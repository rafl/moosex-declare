use strict;
use warnings;
use Test::More tests => 2;
use Test::Moose;

use Moose::Declare;

my $class = class {
    has 'foo' => (
        is  => 'ro',
        isa => 'Str',
    );
};

meta_ok($class);
has_attribute_ok($class, 'foo');
