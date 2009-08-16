use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";

use ParameterizedRole;

can_ok('MyGame::Weapon', 'increment_enchantment');
can_ok('MyGame::Weapon', 'reset_enchantment');

can_ok('MyGame::Wand', 'increment_zapped');
can_ok('MyGame::Wand', 'reset_zapped');

done_testing;
