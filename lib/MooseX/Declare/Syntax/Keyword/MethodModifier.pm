package MooseX::Declare::Syntax::Keyword::MethodModifier;

use Moose;

use MooseX::Method::Signatures::Meta::Method;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

has prototype_beginning => (
    is          => 'rw',
    isa         => 'Str',
);

sub parse {
    my ($self, $ctx) = @_;

    $ctx->skip_declarator;
    local $Carp::Internal{'Devel::Declare'} = 1;

    my $name = $ctx->strip_name;
    return unless defined $name;

    my $proto = $ctx->strip_proto || '';

    $proto = join(', ',
        $self->prototype_beginning || (),
        length($proto) ? $proto : (),
    );

    my $method = MooseX::Method::Signatures::Meta::Method->wrap(
        signature    => qq{(${proto})},
        package_name => $ctx->get_curstash_name,
        name         => $name,
    );

    $ctx->inject_if_block( $ctx->scope_injector_call() . $method->injectable_code );

    my $modifier_name = $ctx->declarator;
    $ctx->shadow(sub (&) {
        my $class = caller();
        $method->_set_actual_body(shift);
        Moose::Util::add_method_modifier($class, $modifier_name, [$name => $method->body]);
    });
}

1;
