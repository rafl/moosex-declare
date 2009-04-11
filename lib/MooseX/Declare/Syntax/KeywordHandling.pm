package MooseX::Declare::Syntax::KeywordHandling;

use Moose::Role;
use Moose::Util::TypeConstraints;
use Devel::Declare ();
use Sub::Install qw( install_sub );
use Moose::Meta::Class ();
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

sub context_class { Context }

sub context_traits { }

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

    # find and load context object class
    my $ctx_class = $self->context_class;
    Class::MOP::load_class $ctx_class;

    my @traits = $self->context_traits;

    # create a context object and initialize it
    my $ctx = $ctx_class->new_with_traits(
        %{ $args },
        caller_file => $caller_file,
        (@traits ? (traits => \@traits) : ()),
    );
    $ctx->init(@ctx_args);

    # parse with current context
    return $self->parse($ctx);
}

1;
