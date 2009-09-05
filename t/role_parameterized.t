use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use ParameterizedRole;

can_ok('MyGame::Weapon', 'increment_enchantment');
can_ok('MyGame::Weapon', 'reset_enchantment');
is(MyGame::Weapon->new->enchantment, 5, 'Provided default for enchantment');

can_ok('MyGame::Wand', 'increment_zapped');
can_ok('MyGame::Wand', 'reset_zapped');
is(MyGame::Wand->new->zapped, 3, 'Provided default for zapped');

can_ok('MyGame::Scroll', 'increment_spelled');
can_ok('MyGame::Scroll', 'reset_spelled');
is(MyGame::Scroll->new->spelled, 1, 'Provided default for spelled');

done_testing;
