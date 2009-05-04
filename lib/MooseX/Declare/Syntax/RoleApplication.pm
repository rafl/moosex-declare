package MooseX::Declare::Syntax::RoleApplication;

use Moose::Role;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::OptionHandling
);

sub add_with_option_customizations {
    my ($self, $ctx, $package, $roles) = @_;

    # consume roles
    $ctx->add_scope_code_parts(
        sprintf 'with %s', join ', ', map { "'$_'" } @{ $roles },
    );

    return 1;
}

1;

=head1 NAME

MooseX::Declare::Syntax::RoleApplication - Handle user specified roles

=head1 DESCRIPTION

This role extends L<MooseX::Declare::Syntax::OptionHandling> and provides
a C<with|/add_with_option_customizations> option.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::OptionHandling>

=back

=head1 METHODS

=head2 add_with_option_customizations

  Object->add_with_option_customizations (
      Object   $context,
      Str      $package,
      ArrayRef $roles,
      HashRef  $options
  )

This will add a call to C<with> in the scope code.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::OptionHandling>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
