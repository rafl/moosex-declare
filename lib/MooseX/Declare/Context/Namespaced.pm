package MooseX::Declare::Context::Namespaced;

use Moose::Role;

use Carp                  qw( croak );
use MooseX::Declare::Util qw( outer_stack_peek );

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

sub qualify_namespace {
    my ($self, $namespace) = @_;

    # only qualify namespaces starting with ::
    return $namespace
        unless $namespace =~ /^::/;

    # try to find the enclosing package
    my $outer = outer_stack_peek($self->caller_file)
        or croak "No outer namespace found to apply relative $namespace to";

    return $outer . $namespace;
}

1;

__END__

=head1 NAME

MooseX::Declare::Context::Namespaced - Namespaced context

=head1 DESCRIPTION

This context trait will add namespace functionality to the context.

=head1 ATTRIBUTES

=head2 namespace

This will be set when the C<strip_namespace> method is called and the
namespace wasn't anonymous. It will contain the specified namespace, not
the fully qualified one.

=head1 METHODS

=head2 strip_namespace

  Maybe[Str] Object->strip_namespace()

This method is intended to parse the main namespace of a namespaced keyword.
It will use L<Devel::Declare::Context::Simple>s C<strip_word> method and store
the result in the L</namespace> attribute if true.

=head2 qualify_namespace

  Str Object->qualify_namespace(Str $namespace)

If the C<$namespace> passed it begins with a C<::>, it will be prefixed with
the outer namespace in the file. If there is no outer namespace, an error
will be thrown.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Context>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut

