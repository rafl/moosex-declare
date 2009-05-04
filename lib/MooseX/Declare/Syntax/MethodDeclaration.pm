package MooseX::Declare::Syntax::MethodDeclaration;

use Moose::Role;
use MooseX::Method::Signatures::Meta::Method;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

requires qw(
    register_method_declaration
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
    return
        unless defined $name;

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
        return $self->register_method_declaration($class, $method);
    });
}

1;

__END__

=head1 NAME

MooseX::Declare::Syntax::MethodDeclaration - Handles method declarations

=head1 DESCRIPTION

A role for keyword handlers that gives a framework to add or modify
methods or things that look like methods.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::KeywordHandling>

=back

=head1 ATTRIBUTES

=head2 prototype_beginning

An optional string that will be prepended to the specified signature that is
specified in the declaration. A popular example is found in the C<around>
L<method modifier handler|MooseX::Declare::Syntax::Keyword::MethodModifier>:

  my $handler = MethodModifier->new(
      identifier          => 'around',
      modifier_type       => 'around',
      prototype_beginning => '$orig: $self',
  );

This will mean that the signature C<(Str $foo)> will become
C<$orig: $self, Str $foo> and C<()> will become C<$orig: $self>.

=head1 REQUIRED METHODS

=head2 register_method_declaration

  Object->register_method_declaration (ClassName $class, Object $method)

This method will be called with the target class name and the final built
L<method meta object|MooseX::Method::Signatures::Meta::Method>. The value
it returns will be the value returned where the method was declared.

=head1 METHODS

=head2 parse

  Object->parse (Object $ctx);

Reads a name and a prototype and builts the method meta object which will
then be passed to L</register_method_declaration>.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::NamespaceHandling>

=item * L<MooseX::Declare::Syntax::MooseSetup>

=item * L<MooseX::Method::Signatures>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
