package MooseX::Declare::Syntax::RoleApplication;

use Moose::Role;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::OptionHandling
);

sub add_with_option_customizations {
    my ($self, $ctx, $package, $roles, $options) = @_;

    # consume roles
    $ctx->add_scope_code_parts(
        sprintf 'with %s', join ', ', map { "'$_'" } @{ $roles },
    );

    return 1;
}

1;
