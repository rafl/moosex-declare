package MooseX::Declare::Context::Namespaced;
use Moose::Role;

use namespace::clean -except => 'meta';

has namespace => (
    is          => 'rw',
    isa         => 'Str',
);

sub strip_namespace {
    my ($self) = @_;

    my $namespace = $self->strip_word;

    $self->namespace($namespace)
        if defined $namespace and length $namespace;

    return $namespace;
}

1;
