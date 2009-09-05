package MooseX::Declare::Context::Parameterized;

use Moose::Role;
use MooseX::Types::Moose qw/Str HashRef/;

use namespace::autoclean;

has parameter_signature => (
    is        => 'rw',
    isa       => Str,
    predicate => 'has_parameter_signature',
);

has parameters => (
    traits    => ['Hash'],
    isa       => HashRef,
    default   => sub { {} },
    handles   => {
        add_parameter  => 'set',
        get_parameters => 'kv',
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
__END__

=head1 NAME

MooseX::Declare::Context::Parameterized - context for parsing optionally parameterized statements

=head1 DESCRIPTION

This context trait will add optional parameterization functionality to the
context.

=head1 ATTRIBUTES

=head2 parameter_signature

This will be set when the C<strip_parameter_signature> method is called and it
was able to extract a list of parameterisations.

=head1 METHODS

=head2 has_parameter_signature

Predicate method for the C<parameter_signature> attribute.

=head2 strip_parameter_signature

  Maybe[Str] Object->strip_parameter_signature()

This method is intended to parse the main namespace of a namespaced keyword.
It will use L<Devel::Declare::Context::Simple>s C<strip_word> method and store
the result in the L</namespace> attribute if true.

=head2 add_parameter

Allows storing parameters extracted from C<parameter_signature> to be used
later on.

=head2 get_parameters

Returns all previously added parameters.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Context>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
