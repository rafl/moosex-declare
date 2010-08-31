package MooseX::Declare::Syntax::Keyword::Method;
# ABSTRACT: Handle method declarations

use Moose;

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

This role is an extension of L<MooseX::Declare::Syntax::MethodDeclaration>
that allows you to install keywords that declare methods.

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::MethodDeclaration>

=cut

with 'MooseX::Declare::Syntax::MethodDeclaration';

=method register_method_declaration

  Object->register_method_declaration (Object $metaclass, Str $name, Object $method)

This method required by the method declaration role will register the finished
method object via the C<< $metaclass->add_method >> method.

  MethodModifier->new(
      identifier           => 'around',
      modifier_type        => 'around',
      prototype_injections => {
          declarator => 'around',
          injections => [ 'CodeRef $orig' ],
      },
  );

This will mean that the signature C<(Str $foo)> will become
C<CodeRef $orig: Object $self, Str $foo> and and C<()> will become
C<CodeRef $orig: Object $self>.

=cut

sub register_method_declaration {
    my ($self, $meta, $name, $method) = @_;
    return $meta->add_method($name, $method);
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::MooseSetup>
* L<MooseX::Declare::Syntax::MethodDeclaration>
* L<MooseX::Method::Signatures>

=cut

1;
