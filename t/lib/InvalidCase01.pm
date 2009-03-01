use MooseX::Declare;
use MooseX::Method::Signatures;


class InvalidCase01 {

  use Carp qw/croak/;

  method _recurse_where(@clauses) {
    croak "Binary operator $op expects 2 children, got " . $#$_
      if @{$_} > 3;

  }

  method _func_after_error {
  }


};

1;
