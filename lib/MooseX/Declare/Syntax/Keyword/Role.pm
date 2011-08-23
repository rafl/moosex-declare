package MooseX::Declare::Syntax::Keyword::Role;
# ABSTRACT: Role declarations

use Moose;
use Moose::Util qw(does_role);
use aliased 'Parse::Method::Signatures' => 'PMS';
use aliased 'MooseX::Declare::Syntax::MethodDeclaration';
use aliased 'Parse::Method::Signatures::Param::Placeholder';
use aliased 'MooseX::Declare::Context::Parameterized', 'ParameterizedCtx';
use aliased 'MooseX::Declare::Syntax::MethodDeclaration::Parameterized', 'ParameterizedMethod';

use namespace::clean -except => 'meta';

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::MooseSetup>
* L<MooseX::Declare::Syntax::RoleApplication>

=cut

with qw(
    MooseX::Declare::Syntax::MooseSetup
    MooseX::Declare::Syntax::RoleApplication
);

=head1 MODIFIED METHODS

=head2 imported_moose_symbols

  List Object->imported_moose_symbols ()

Extends the existing L<MooseX::Declare::Syntax::MooseSetup/imported_moose_symbols>
with C<requires>, C<extends>, C<has>, C<inner> and C<super>.

=cut

around imported_moose_symbols => sub { shift->(@_), qw( requires excludes extends has inner super ) };

=head2 import_symbols_from

  Str Object->import_symbols_from ()

Will return L<Moose::Role> instead of the default L<Moose>.

=cut

around import_symbols_from => sub {
    my ($next, $self, $ctx) = @_;
    return $ctx->has_parameter_signature
        ? 'MooseX::Role::Parameterized'
        : 'Moose::Role';
};

=head2 make_anon_metaclass

  Object Object->make_anon_metaclass ()

This will return an anonymous instance of L<Moose::Meta::Role>.

=cut

around make_anon_metaclass => sub { Moose::Meta::Role->create_anon_role };

around context_traits => sub { shift->(@_), ParameterizedCtx };

around default_inner => sub {
    my ($next, $self, $stack) = @_;
    my $inner = $self->$next;
    return $inner
        if !@{ $stack || [] } || !$stack->[-1]->is_parameterized;

    ParameterizedMethod->meta->apply($_)
        for grep { does_role($_, MethodDeclaration) } @{ $inner };

    return $inner;
};

=method generate_export

  CodeRef Object->generate_export ()

Returns a closure with a call to L</make_anon_metaclass>.

=cut

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
        from_namespace => $ctx->get_curstash_name,
    );
    confess 'Positional parameters are not allowed in parameterized roles'
        if $sig->has_positional_params;

    my @vars = map {
        does_role($_, Placeholder)
            ? ()
            : {
                var  => $_->variable_name,
                name => $_->label,
                tc   => $_->meta_type_constraint,
                ($_->has_default_value
                    ? (default => $_->default_value)
                    : ()),
            },
    } $sig->named_params;

    $ctx->add_preamble_code_parts(
        sprintf 'my (%s) = map { $_[0]->$_ } qw(%s);',
            join(',', map { $_->{var}  } @vars),
            join(' ', map { $_->{name} } @vars),
    );

    for my $var (@vars) {
        $ctx->add_parameter($var->{name} => {
            is  => 'ro',
            isa => $var->{tc},
            (exists $var->{default}
                ? (default => sub { eval $var->{default} })
                : ()),
        });
    }
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

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::Keyword::Class>
* L<MooseX::Declare::Syntax::RoleApplication>
* L<MooseX::Declare::Syntax::MooseSetup>

=cut

1;
