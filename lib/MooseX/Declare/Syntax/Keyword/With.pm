package MooseX::Declare::Syntax::Keyword::With;

use Moose;
use Moose::Util;
use MooseX::Declare::Util qw( outer_stack_peek );
use namespace::autoclean;

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

sub parse {
    my ($self, $ctx) = @_;

    $ctx->skip_declarator;
    $ctx->skipspace;

    my $next_char = $ctx->peek_next_char;
    if ($next_char =~ /^[\w(:]$/) {
        confess "Declarative 'with' not implemented yet. Use the normal Moose 'with' syntax.";
    }

    my $pkg = outer_stack_peek $ctx->caller_file;
    $ctx->shadow(sub { Moose::Util::apply_all_roles($pkg, @_) });
}

1;
