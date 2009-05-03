use strict;
use warnings;

package MooseX::Declare::Util;

use Sub::Exporter -setup => {
    exports => [qw(
        outer_stack_push
        outer_stack_pop
        outer_stack_peek
    )],
};

my %OuterStack;

sub outer_stack_push {
    my ($file, $value) = @_;

    push @{ $OuterStack{ $file } }, $value;
    return $value;
}

sub outer_stack_pop {
    my ($file) = @_;

    return undef
        unless @{ $OuterStack{ $file } || [] };
    return pop @{ $OuterStack{ $file } };
}

sub outer_stack_peek {
    my ($file) = @_;

    return undef
        unless @{ $OuterStack{ $file } || [] };
    return $OuterStack{ $file }[-1];
}

1;

=head1 NAME

MooseX::Declare::Util - Common declarative utility functions

=head1 DESCRIPTION

This exporter collection contains the commonly used functions in L<MooseX::Declare>.

=head1 EXPORTS

=head2 outer_stack_push

  outer_stack_push (Str $file, Str $value)

Pushes the C<$value> on the internal stack for the file C<$file>.

=head2 outer_stack_pop

  outer_stack_pop (Str $file)

Removes one item from the internal stack of the file C<$file>.

=head2 outer_stack_peek

  outer_stack_peek (Str $file)

Returns the topmost item in the internal stack for C<$file> without removing
it from the stack.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
