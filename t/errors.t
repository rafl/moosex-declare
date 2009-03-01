use strict;
use warnings;
use Test::More tests => 1;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";

eval "use InvalidCase01;";
unlike($@, qr/^BEGIN not safe after errors--compilation aborted/s, "Sane error message");
