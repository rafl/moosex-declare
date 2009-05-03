package MooseX::Declare::Syntax::Keyword::Clean;

use Moose;

use constant NAMESPACING_ROLE => 'MooseX::Declare::Syntax::NamespaceHandling';
use Carp qw( cluck );

use namespace::clean -except => 'meta';

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

1;
