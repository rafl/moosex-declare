package MooseX::Declare::Syntax::Keyword::Method;

use Moose;

use namespace::clean -except => 'meta';

with 'MooseX::Declare::Syntax::MethodDeclaration';

sub register_method_declaration {
    my ($self, $meta, $name, $method) = @_;
    return $meta->add_method($name, $method);
}

1;

__END__

=head1 NAME

MooseX::Declare::Syntax::Keyword::Method - Handle method declarations

=head1 DESCRIPTION

This role is an extension of L<MooseX::Declare::Syntax::MethodDeclaration>
that allows you to install keywords that declare methods.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::MethodDeclaration>

=back

=head1 METHODS

=head2 register_method_declaration

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

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::MooseSetup>

=item * L<MooseX::Declare::Syntax::MethodDeclaration>

=item * L<MooseX::Method::Signatures>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
