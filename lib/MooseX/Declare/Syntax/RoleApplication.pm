package MooseX::Declare::Syntax::RoleApplication;

use Moose::Role;

use aliased 'MooseX::Declare::Context::Namespaced';

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::OptionHandling
);

around context_traits => sub { shift->(@_), Namespaced };

sub add_with_option_customizations {
    my ($self, $ctx, $package, $roles) = @_;

    # consume roles
    $ctx->add_early_cleanup_code_parts(
        sprintf 'Moose::Util::apply_all_roles(%s->meta, %s)',
            $package,
            join ', ',
            map  { "q[$_]" }
            map  { $ctx->qualify_namespace($_) }
                @{ $roles },
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
