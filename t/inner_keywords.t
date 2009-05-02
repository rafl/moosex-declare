use Test::More tests => 6;

use MooseX::Declare;

for my $inner (qw( method around before after augment override )) {
    eval $inner . ' foo ($bar) { }';
    ok($@, "$inner keyword not set up outside of classes");
}
