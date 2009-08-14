use strict;
use warnings;
use Test::More;;
use Test::Moose;

use MooseX::Declare;

role Rollo { }

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

my $meta_class_2 = class with Rollo;

isa_ok($meta_class_2, 'Moose::Meta::Class');
ok($meta_class_2->is_immutable);

$class = $meta_class_2->name;
meta_ok($class);
can_ok($class, 'new');
does_ok($class, 'Rollo');

my $meta_class_3 = class();

isa_ok($meta_class_3, 'Moose::Meta::Class', 'class() works');

done_testing;
