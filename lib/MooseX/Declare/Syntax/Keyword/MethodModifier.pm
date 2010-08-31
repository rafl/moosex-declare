package MooseX::Declare::Syntax::Keyword::MethodModifier;
# ABSTRACT: Handle method modifier declarations

use Moose;
use Moose::Util;
use Moose::Util::TypeConstraints;

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

Allows the implementation of method modification handlers like C<around> and
C<before>.

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::MethodDeclaration>

=cut

with 'MooseX::Declare::Syntax::MethodDeclaration';

=attr modifier_type

A required string that is one of:

=for :list
* around
* after
* before
* override
* augment

=cut

has modifier_type => (
    is          => 'rw',
    isa         => enum(undef, qw( around after before override augment )),
    required    => 1,
);

=method register_method_declaration

  Object->register_method_declaration (Object $metaclass, Str $name, Object $method)

This will add the method modifier to the C<$metaclass> via L<Moose::Util>s
C<add_method_modifier>, whose return value will also be returned from this
method.

=cut

sub register_method_declaration {
    my ($self, $meta, $name, $method) = @_;
    return Moose::Util::add_method_modifier($meta->name, $self->modifier_type, [$name, $method->body]);
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::MooseSetup>
* L<MooseX::Declare::Syntax::MethodDeclaration>
* L<MooseX::Method::Signatures>

=cut

1;
