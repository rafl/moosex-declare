use strict;
use warnings;
use Test::More tests => 5;
use Test::Moose;

use MooseX::Declare;

my $meta_class = class {
    has 'foo' => (
        is  => 'ro',
        isa => 'Str',
    );
};

isa_ok($meta_class, 'Moose::Meta::Class');

my $class = $meta_class->name;
meta_ok($class);
can_ok($class, 'new');
has_attribute_ok($class, 'foo');

ok(!__PACKAGE__->can('augment'));
