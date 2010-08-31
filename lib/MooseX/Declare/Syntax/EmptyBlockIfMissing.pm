package MooseX::Declare::Syntax::EmptyBlockIfMissing;
# ABSTRACT: Handle missing blocks after keywords

use Moose::Role;

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

The L<MooseX::Declare::Syntax::NamespaceHandling> role will require that the
consumer handles the case of non-existant blocks. This role will inject
an empty block with only the generated code parts in it.

=method handle_missing_block

  Object->handle_missing_block (Object $context, Str $body, %args)

This will inject the generated code surrounded by C<{ ... }> into the code
where the keyword was called.

=cut

sub handle_missing_block {
    my ($self, $ctx, $inject, %args) = @_;

    # default to block with nothing more than the default contents
    $ctx->inject_code_parts_here("{ $inject }");
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::NamespaceHandling>

=cut

1;
