package MooseX::Declare::Syntax::Keyword::Method;

use Moose;

use namespace::clean -except => 'meta';

with 'MooseX::Declare::Syntax::MethodDeclaration';

sub register_method_declaration {
    my ($self, $class, $method) = @_;
    return $class->meta->add_method($method->name, $method->body);
}

1;
