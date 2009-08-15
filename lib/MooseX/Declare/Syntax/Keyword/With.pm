package MooseX::Declare::Syntax::Keyword::With;

use Moose;
use Moose::Util;
use MooseX::Declare::Util qw( outer_stack_peek );
use aliased 'MooseX::Declare::Context::Namespaced';
use namespace::autoclean;

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

around context_traits => sub { shift->(@_), Namespaced };

sub parse {
    my ($self, $ctx) = @_;

    $ctx->skip_declarator;

    my $pkg = outer_stack_peek $ctx->caller_file;
    $ctx->shadow(sub {
        Moose::Util::apply_all_roles($pkg, map {
            $ctx->qualify_namespace($_)
        } @_);
    });
}

1;
