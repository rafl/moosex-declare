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
