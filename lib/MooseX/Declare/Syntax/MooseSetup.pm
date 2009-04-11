package MooseX::Declare::Syntax::MooseSetup;
 
use Moose::Role;

use Moose::Util  qw( find_meta );
use Sub::Install qw( install_sub );

use aliased 'MooseX::Declare::Syntax::Keyword::MethodModifier';
use aliased 'MooseX::Declare::Syntax::Keyword::Clean', 'CleanKeyword';

use namespace::clean -except => 'meta';

our @Roles;

with qw(
    MooseX::Declare::Syntax::NamespaceHandling
    MooseX::Declare::Syntax::EmptyBlockIfMissing
);

sub auto_make_immutable { 0 }

sub imported_moose_symbols { qw( confess blessed ) }

sub import_symbols_from { 'Moose' }

around default_inner => sub {
    return [
        MethodModifier->new(
            identifier          => 'around',
            modifier_type       => 'around',
            prototype_beginning => '$orig: $self',
        ),
        CleanKeyword->new(
            identifier          => 'clean',
        ),
        map { MethodModifier->new(identifier => $_, modifier_type => $_) }
            qw( after before override augment ),
    ];
};

after add_namespace_customizations => sub {
    my ($self, $ctx, $package, $options) = @_;

    # add Moose initializations to preamble
    $ctx->add_preamble_code_parts(
        sprintf 'use %s qw( %s )', $self->import_symbols_from, join ' ', $self->imported_moose_symbols,
    );

    # make class immutable unless specified otherwise
    $ctx->add_cleanup_code_parts(
        "${package}->meta->make_immutable",
    ) if $self->auto_make_immutable
         and not exists $options->{is}{mutable};
};

after handle_post_parsing => sub {
    my ($self, $ctx, $package, $class) = @_;

    # finish off by apply the roles
    my $create_class = sub {
        local @Roles = ();
        shift->();
        Moose::Util::apply_all_roles(find_meta($package), @Roles)
            if @Roles;
    };

    $ctx->shadow(sub (&) { $create_class->(@_); return $class; });
};

after setup_inner_for => sub {
    my ($self, $setup_class) = @_;

    # install role collector
    install_sub({
        code    => sub { push @Roles, @_ },
        into    => $setup_class,
        as      => 'with',
    });
};

1;
