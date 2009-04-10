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
