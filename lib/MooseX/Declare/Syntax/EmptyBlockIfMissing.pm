package MooseX::Declare::Syntax::EmptyBlockIfMissing;

use Moose::Role;

use namespace::clean -except => 'meta';

sub handle_missing_block {
    my ($self, $ctx, $inject, %args) = @_;

    # default to block with nothing more than the default contents
    $ctx->inject_code_parts_here("{ $inject }");
}

1;
