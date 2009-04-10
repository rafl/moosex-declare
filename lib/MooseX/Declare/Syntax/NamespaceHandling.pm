package MooseX::Declare::Syntax::NamespaceHandling;

use Moose::Role;

use MooseX::Declare::Util qw( outer_stack_peek );

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

sub parse {
    my ($self, $ctx) = @_;

    # keyword comes first
    $ctx->skip_declarator;

    # read the name and unwrap the options
    my ($name, $options) = $ctx->strip_name_and_options;
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
    elsif (not(keys %$options) and $ctx->peek_next_char ne '{') {
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
            "use MooseX::Declare %s => '%s', file => __FILE__, stack => [qw( %s )]",
            outer_package => $package,
            join(' ', @{ $ctx->stack }, $self->identifier),
        ),
    );

    # allow consumer to provide specialisations
    $self->add_namespace_customizations($ctx, $package, $options);

    # make options a separate step
    $self->add_optional_customizations($ctx, $package, $options);

    # finish off preamble with a namespace cleanup
    $ctx->add_preamble_code_parts(
        'use namespace::clean -except => [qw( meta )]',
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
