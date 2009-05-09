package MooseX::Declare::Syntax::Keyword::Method;

use Moose;

use namespace::clean -except => 'meta';

with 'MooseX::Declare::Syntax::MethodDeclaration';

sub register_method_declaration {
    my ($self, $class, $method) = @_;
    return $class->meta->add_method($method->name, $method);
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

  Object->register_method_declaration (ClassName $class, Object $method)

This method required by the method declaration role will register the finished
method object via the C<$class> metaclass instance's C<add_method> method.

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
