package MooseX::Declare::Syntax::Extending;
# ABSTRACT: Extending with superclasses

use Moose::Role;

use aliased 'MooseX::Declare::Context::Namespaced';

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

Extends a class by a specified C<extends> option.

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::OptionHandling>

=cut

with qw(
    MooseX::Declare::Syntax::OptionHandling
);

around context_traits => sub { shift->(@_), Namespaced };

=method add_extends_option_customizations

  Object->add_extends_option_customizations (
      Object   $ctx,
      Str      $package,
      ArrayRef $superclasses,
      HashRef  $options
  )

This will add a code part that will call C<extends> with the C<$superclasses>
as arguments.

=cut

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

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::Keyword::Class>
* L<MooseX::Declare::Syntax::OptionHandling>

=cut

1;
