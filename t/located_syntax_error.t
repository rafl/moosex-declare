use strict;
use warnings;
use Test::More;
use Test::Moose;

use FindBin;
use lib "$FindBin::Bin/lib";

eval q{ use Invalid1; };
my $error = $@;

ok(defined $error, "recognized that does is bad syntax");
like($error, qr/Invalid1\.pm/, "found the error in the right file");
like($error, qr/5/, "found the error in the right line");

eval q{ use Invalid2; };
$error = $@;

ok(defined $error, "recognized a runaway { as bad syntax");
like($error, qr/Invalid2\.pm/, "found the error in the right file");
like($error, qr/6/, "found the error in the right line");

done_testing;
