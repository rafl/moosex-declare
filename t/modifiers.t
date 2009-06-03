use Test::More;
use MooseX::Declare;

my @log = ();
BEGIN { $SIG{__WARN__} = sub { push @log, \@_ } };

role Bar {
  before do_foo {
    push @log, { before => 'string' };
  }
}

class Foo with Bar {
  method do_foo {
    push @log, { class => 'string' };
  }
}

Foo->new->do_foo;

is_deeply(\@log, [{'before', 'string'}, {'class','string'}] );

done_testing;
