package MooseX::Declare::Syntax::NamespaceHandling;

use Moose::Role;
use MooseX::Declare::Util   qw( outer_stack_peek );

use aliased 'MooseX::Declare::Context::Namespaced';
use aliased 'MooseX::Declare::Context::WithOptions';
use aliased 'MooseX::Declare::StackItem';

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::KeywordHandling
    MooseX::Declare::Syntax::InnerSyntaxHandling
);

requires qw(
    handle_missing_block
);

sub add_namespace_customizations { }
sub add_optional_customizations  { }
sub handle_post_parsing          { }
sub make_anon_metaclass          { }

around context_traits => sub { super, WithOptions, Namespaced };

sub parse_specification {
    my ($self, $ctx) = @_;

    $self->parse_namespace_specification($ctx);
    $self->parse_option_specification($ctx);

    return;
}

sub parse_namespace_specification {
    my ($self, $ctx) = @_;
    return scalar $ctx->strip_namespace;
}

sub parse_option_specification {
    my ($self, $ctx) = @_;
    return scalar $ctx->strip_options;
}

sub generate_inline_stack {
    my ($self, $ctx) = @_;

    return join ', ',
        map { $_->serialize }
            @{ $ctx->stack },
            $self->generate_current_stack_item($ctx);
}

sub generate_current_stack_item {
    my ($self, $ctx) = @_;

    return StackItem->new(
        identifier    => $self->identifier,
        is_dirty      => $ctx->options->{is}{dirty},
        handler       => ref($self),
        namespace     => $ctx->namespace,
    );
}

sub parse {
    my ($self, $ctx) = @_;

    # keyword comes first
    $ctx->skip_declarator;

    # read the name and unwrap the options
    $self->parse_specification($ctx);

    my $name    = $ctx->namespace;

    my ($package, $anon);

    # we have a name in the declaration, which will be used as package name
    if (defined $name) {
        $package = $name;

        # there is an outer namespace stack item, meaning we namespace below it
        if (my $outer = outer_stack_peek $ctx->caller_file) {
            $package = join '::' => $outer, $package;
        }
    }

    # no name, no options, no block. Probably { class => 'foo' }
    elsif (not(keys %{ $ctx->options }) and $ctx->peek_next_char ne '{') {
        return;
    }

    # we have options and/or a block, but not name
    else {
        $anon = $self->make_anon_metaclass
            or die "make_anon_metaclass did not return an anonymous meta class\n";
        $package = $anon->name;
    }

    # namespace and mx:d initialisations
    $ctx->add_preamble_code_parts(
        "package ${package}",
        sprintf(
            "use MooseX::Declare %s => '%s', file => __FILE__, stack => [ %s ]",
            outer_package => $package,
            $self->generate_inline_stack($ctx),
        ),
    );

    # allow consumer to provide specialisations
    $self->add_namespace_customizations($ctx, $package);

    # make options a separate step
    $self->add_optional_customizations($ctx, $package);

    # finish off preamble with a namespace cleanup
    $ctx->add_preamble_code_parts(
        $ctx->options->{is}->{dirty}
            ? 'use namespace::clean -except => [qw( meta )]'
            : 'use namespace::autoclean'
    );

    # clean up our stack afterwards, if there was a name
    $ctx->add_cleanup_code_parts(
        ['BEGIN',
            'MooseX::Declare::Util::outer_stack_pop __FILE__',
        ],
    );

    # actual code injection
    $ctx->inject_code_parts(
        inject_cleanup_code_parts => defined($name),
        missing_block_handler     => sub { $self->handle_missing_block(@_) },
    );

    # a last chance to change things
    $self->handle_post_parsing($ctx, $package, defined($name) ? $name : $anon);
}

1;
