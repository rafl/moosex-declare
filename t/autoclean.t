use MooseX::Declare;
use Test::More tests => 9;

class Foo {
    use Carp 'croak';
}

class Bar is dirty {
    use Carp 'croak';
}

class Baz is clean {
    use Carp 'croak';
}

my $clean_has_warned;
BEGIN {
    $SIG{__WARN__} = sub {
        my ($message) = @_;
        if ($message =~ /Attempted to clean an already cleaned namespace/i) {
            $clean_has_warned = $message;
            return;
        }
        warn $message;
    };
}

class Qux {
    use Carp 'croak';
    clean;
}

my $clean_has_not_warned;
BEGIN {
    $clean_has_not_warned = 1;
    $SIG{__WARN__} = sub {
        my ($message) = @_;
        if ($message =~ /Attempted to clean an already cleaned namespace/i) {
            $clean_has_warned = 0;
            return;
        }
        warn $message;
    };
}

class Quux is dirty {
    use Carp 'croak';
    clean;
}

undef $SIG{__WARN__};

ok(!Foo->can('croak'), '... Foo is clean');
ok( Bar->can('croak'), '... Bar is dirty');
ok(!Baz->can('croak'), '... Baz is clean');

ok(!Qux->can('croak'), '... Qux is clean');
ok($clean_has_warned, 'Qux usage of clean and autoclean leads to warning');
like($clean_has_warned, qr/is dirty/, 'warning contains "is dirty" hint');
like($clean_has_warned, qr/Qux/, 'warning contains Qux namespace');

ok(!Quux->can('croak'), '... Quux is clean');
ok($clean_has_not_warned, 'Quux usage of clean in a dirty class leads to no warning');

