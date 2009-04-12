package MooseX::Declare::Syntax::Keyword::Role;

use Moose;
use B::Compiling;
use Moose::Util qw(does_role);
use aliased 'Parse::Method::Signatures' => 'PMS';
use aliased 'MooseX::Declare::Context::Parameterized';
use aliased 'Parse::Method::Signatures::Param::Placeholder';

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::MooseSetup
    MooseX::Declare::Syntax::RoleApplication
);

around imported_moose_symbols => sub { shift->(@_), qw( requires excludes extends has inner super ) };

around import_symbols_from => sub {
    my ($next, $self, $ctx) = @_;
    return $ctx->has_parameter_signature
        ? 'MooseX::Role::Parameterized'
        : 'Moose::Role';
};

around make_anon_metaclass => sub { Moose::Meta::Role->create_anon_role };

around context_traits => sub { shift->(@_), Parameterized };

sub generate_export { my $self = shift; sub { $self->make_anon_metaclass } }

after parse_namespace_specification => sub {
    my ($self, $ctx) = @_;
    $ctx->strip_parameter_signature;
};

after add_namespace_customizations => sub {
    my ($self, $ctx, $package, $options) = @_;
    $self->add_parameterized_customizations($ctx, $package, $options)
        if $ctx->has_parameter_signature;
};

sub add_parameterized_customizations {
    my ($self, $ctx, $package, $options) = @_;

    my $sig = PMS->signature(
        input          => "(${\$ctx->parameter_signature})",
        from_namespace => PL_compiling->stashpv,
    );
    confess 'positional parameter in parameterized role'
        if $sig->has_positional_params;

    my @vars = map {
        does_role($_, Placeholder)
            ? ()
            : [$_->variable_name, $_->label, $_->meta_type_constraint]
    } $sig->named_params;

    $ctx->add_preamble_code_parts(
        sprintf 'my (%s) = map { $_[0]->$_ } qw(%s);',
            join(',', map { $_->[0] } @vars),
            join(' ', map { $_->[1] } @vars),
    );

    $ctx->add_parameter($_->[1] => { isa => $_->[2] }) for @vars;
}

after handle_post_parsing => sub {
    my ($self, $ctx, $package, $class) = @_;
    return unless $ctx->has_parameter_signature;
    $ctx->shadow(sub (&) {
        my $meta = Class::MOP::class_of($class);
        $meta->add_parameter($_->[0], %{ $_->[1] })
            for $ctx->get_parameters;
        $meta->role_generator($_[0]);
        return $class;
    });
};

1;
