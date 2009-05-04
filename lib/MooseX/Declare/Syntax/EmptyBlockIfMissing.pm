package MooseX::Declare::Syntax::EmptyBlockIfMissing;

use Moose::Role;

use namespace::clean -except => 'meta';

sub handle_missing_block {
    my ($self, $ctx, $inject, %args) = @_;

    # default to block with nothing more than the default contents
    $ctx->inject_code_parts_here("{ $inject }");
}

1;

__END__

=head1 NAME

MooseX::Declare::Syntax::EmptyBlockIfMissing

=head1 DESCRIPTION

The L<MooseX::Declare::Syntax::NamespaceHandling> role will require that the
consumer handles the case of non-existant blocks. This role will inject
an empty block with only the generated code parts in it.

=head1 METHODS

=head2 handle_missing_block

  Object->handle_missing_block (Object $context, Str $body, %args)

This will inject the generated code surrounded by C<{ ... }> into the code
where the keyword was called.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::NamespaceHandling>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
