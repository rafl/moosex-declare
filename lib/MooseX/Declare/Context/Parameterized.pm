package MooseX::Declare::Context::Parameterized;

use Moose::Role;
use MooseX::AttributeHelpers;

use namespace::clean -except => 'meta';

has parameter_signature => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_parameter_signature',
);

has parameters => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef',
    default   => sub { {} },
    provides  => {
        set => 'add_parameter',
        kv  => 'get_parameters',
    },
);

sub strip_parameter_signature {
    my ($self) = @_;

    my $signature = $self->strip_proto;

    $self->parameter_signature($signature)
        if defined $signature && length $signature;

    return $signature;
}

1;
