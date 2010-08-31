package MooseX::Declare::Context::Parameterized;
# ABSTRACT: context for parsing optionally parameterized statements

use Moose::Role;
use MooseX::Types::Moose qw/Str HashRef/;

use namespace::autoclean;

=head1 DESCRIPTION

This context trait will add optional parameterization functionality to the
context.

=attr parameter_signature

This will be set when the C<strip_parameter_signature> method is called and it
was able to extract a list of parameterisations.

=method has_parameter_signature

Predicate method for the C<parameter_signature> attribute.

=cut

has parameter_signature => (
    is        => 'rw',
    isa       => Str,
    predicate => 'has_parameter_signature',
);

=method add_parameter

Allows storing parameters extracted from C<parameter_signature> to be used
later on.

=method get_parameters

Returns all previously added parameters.

=cut

has parameters => (
    traits    => ['Hash'],
    isa       => HashRef,
    default   => sub { {} },
    handles   => {
        add_parameter  => 'set',
        get_parameters => 'kv',
    },
);

=method strip_parameter_signature

  Maybe[Str] Object->strip_parameter_signature()

This method is intended to parse the main namespace of a namespaced keyword.
It will use L<Devel::Declare::Context::Simple>s C<strip_word> method and store
the result in the L</namespace> attribute if true.

=cut

sub strip_parameter_signature {
    my ($self) = @_;

    my $signature = $self->strip_proto;

    $self->parameter_signature($signature)
        if defined $signature && length $signature;

    return $signature;
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Context>

=cut

1;
