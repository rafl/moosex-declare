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
