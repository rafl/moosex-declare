use strict;
use warnings;
use Test::More tests => 1;
use Test::Moose;

use FindBin;
use lib "$FindBin::Bin/lib";

use Affe;
meta_ok('Tiger', "namespaces aren't nested, although Tiger is loaded from within the Affe class definition");
