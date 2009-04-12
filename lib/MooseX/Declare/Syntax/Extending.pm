package MooseX::Declare::Syntax::Extending;

use Moose::Role;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::OptionHandling
);

sub add_extends_option_customizations {
    my ($self, $ctx, $package, $superclasses, $options) = @_;

    # add code for extends keyword
    $ctx->add_scope_code_parts(
        sprintf 'extends %s', join ', ', map { "'$_'" } @{ $superclasses },
    );

    return 1;
}

1;
