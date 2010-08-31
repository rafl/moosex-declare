package MooseX::Declare::Syntax::Keyword::Clean;
# ABSTRACT: Explicit namespace cleanups

use Moose;

use constant NAMESPACING_ROLE => 'MooseX::Declare::Syntax::NamespaceHandling';
use Carp qw( cluck );

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

This keyword will inject a call to L<namespace::clean> into its current
position.

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::KeywordHandling>

=cut

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

sub find_namespace_handler {
    my ($self, $ctx) = @_;

    for my $item (reverse @{ $ctx->stack }) {
        return $item
            if $item->handler->does(NAMESPACING_ROLE);
    }

    return undef;
}

=method parse

  Object->parse(Object $context)

This will inject a call to L<namespace::clean> C<-except => 'meta'> into
the code at the position of the keyword.

=cut

sub parse {
    my ($self, $ctx) = @_;

    if (my $stack_item = $self->find_namespace_handler($ctx)) {
        my $namespace = $stack_item->namespace;

        cluck "Attempted to clean an already cleaned namespace ($namespace). Did you mean to use 'is dirty'?"
            unless $stack_item->is_dirty;
    }

    $ctx->skip_declarator;
    $ctx->inject_code_parts_here(
        ';use namespace::clean -except => [qw( meta )]',
    );
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::KeywordHandling>

=cut

1;
