package MooseX::Declare::Syntax::Keyword::Clean;

use Moose;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

sub parse {
    my ($self, $ctx) = @_;

    $ctx->skip_declarator;
    $ctx->inject_code_parts_here(
        ';use namespace::clean -except => [qw( meta )]',
    );
}

1;

=head1 NAME

MooseX::Declare::Syntax::Keyword::Clean - Explicit namespace cleanups

=head1 DESCRIPTION

This keyword will inject a call to L<namespace::clean> into its current
position.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::KeywordHandling>

=back

=head1 METHODS

=head2 parse

  Object->parse(Object $context)

This will inject a call to L<namespace::clean> C<-except => 'meta'> into
the code at the position of the keyword.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::KeywordHandling>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
