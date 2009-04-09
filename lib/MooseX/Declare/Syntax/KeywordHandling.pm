package MooseX::Declare::Syntax::KeywordHandling;

use Moose::Role;

use Moose::Util::TypeConstraints;
use Devel::Declare ();
use Sub::Install qw( install_sub );

use aliased 'MooseX::Declare::Context';

use namespace::clean -except => 'meta';

requires qw(
    parse
);

has identifier => (
    is          => 'ro',
    isa         => subtype(as 'Str', where { /^ [_a-z] [_a-z0-9]* $/ix }),
    required    => 1,
);

sub get_identifier { shift->identifier }

sub setup_for {
    my ($self, $setup_class, %args) = @_;

    # make sure the stack is valid
    my $stack = $args{stack} || [];
    my $ident = $self->get_identifier;

    # setup the D:D handler for our keyword
    Devel::Declare->setup_for($setup_class, {
        $ident => {
            const => sub { $self->parse_declaration((caller(1))[1], \%args, @_) },
        },
    });

    # search or generate a real export
    my $export = $self->can('generate_export') ? $self->generate_export($setup_class) : sub { };

    # export subroutine
    install_sub({
        code    => $export,
        into    => $setup_class,
        as      => $ident,
    }) unless $setup_class->can($ident);

    return 1;
}

sub parse_declaration {
    my ($self, $caller_file, $args, @ctx_args) = @_;

    # create a context object and initialize it
    (my $ctx = Context->new(%{ $args }, caller_file => $caller_file))->init(@ctx_args);

    # parse with current context
    return $self->parse($ctx);
}

1;
