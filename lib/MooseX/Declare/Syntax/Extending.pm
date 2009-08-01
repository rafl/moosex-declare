package MooseX::Declare::Syntax::Extending;

use Moose::Role;

use aliased 'MooseX::Declare::Context::Namespaced';

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::OptionHandling
);

around context_traits => sub { shift->(@_), Namespaced };

sub add_extends_option_customizations {
    my ($self, $ctx, $package, $superclasses) = @_;

    # add code for extends keyword
    $ctx->add_scope_code_parts(
        sprintf 'extends %s',
            join ', ',
            map  { "'$_'" }
            map  { $ctx->qualify_namespace($_) }
                @{ $superclasses },
    );

    return 1;
}

1;

__END__

=head1 NAME

MooseX::Declare::Syntax::Extending - Extending with superclasses

=head1 DESCRIPTION

Extends a class by a specified C<extends> option.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::OptionHandling>

=back

=head1 METHODS

=head2 add_extends_option_customizations

  Object->add_extends_option_customizations (
      Object   $ctx,
      Str      $package,
      ArrayRef $superclasses,
      HashRef  $options
  )

This will add a code part that will call C<extends> with the C<$superclasses>
as arguments.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::Keyword::Class>

=item * L<MooseX::Declare::Syntax::OptionHandling>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
