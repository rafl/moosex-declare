use strict;
use warnings;

package MooseX::Declare::Util;
# ABSTRACT: Common declarative utility functions

use Sub::Exporter -setup => {
    exports => [qw(
        outer_stack_push
        outer_stack_pop
        outer_stack_peek
    )],
};

=head1 DESCRIPTION

This exporter collection contains the commonly used functions in
L<MooseX::Declare>.

All functions in this package will be exported upon request.

=cut

my %OuterStack;


=func outer_stack_push

  outer_stack_push (Str $file, Str $value)

Pushes the C<$value> on the internal stack for the file C<$file>.

=cut

sub outer_stack_push {
    my ($file, $value) = @_;

    push @{ $OuterStack{ $file } }, $value;
    return $value;
}

=func outer_stack_pop

  outer_stack_pop (Str $file)

Removes one item from the internal stack of the file C<$file>.

=cut

sub outer_stack_pop {
    my ($file) = @_;

    return undef
        unless @{ $OuterStack{ $file } || [] };
    return pop @{ $OuterStack{ $file } };
}

=func outer_stack_peek

  outer_stack_peek (Str $file)

Returns the topmost item in the internal stack for C<$file> without removing
it from the stack.

=cut

sub outer_stack_peek {
    my ($file) = @_;

    return undef
        unless @{ $OuterStack{ $file } || [] };
    return $OuterStack{ $file }[-1];
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>

=cut

1;
