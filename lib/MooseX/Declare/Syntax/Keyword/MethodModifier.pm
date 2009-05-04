package MooseX::Declare::Syntax::Keyword::MethodModifier;

use Moose;
use Moose::Util;
use Moose::Util::TypeConstraints;

use namespace::clean -except => 'meta';

with 'MooseX::Declare::Syntax::MethodDeclaration';

has modifier_type => (
    is          => 'rw',
    isa         => enum(undef, qw( around after before override augment )),
    required    => 1,
);

sub register_method_declaration {
    my ($self, $class, $method) = @_;
    return Moose::Util::add_method_modifier($class, $self->modifier_type, [$method->name, $method->body]);
}

1;

__END__

=head1 NAME

MooseX::Declare::Syntax::Keyword::MethodModifier - Handle method modifier declarations

=head1 DESCRIPTION

Allows the implementation of method modification handlers like C<around> and
C<before>.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::MethodDeclaration>

=back

=head1 ATTRIBUTES

=head2 modifier_type

A required string that is one of:

  around
  after
  before
  override
  augment

=head1 METHODS

=head2 register_method_declaration

  Object->register_method_declaration (ClassName $class, Object $method)

This will add the method modifier to the C<$class> via L<Moose::Util>s
C<add_method_modifier>, whose return value will also be returned from this
method.

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
