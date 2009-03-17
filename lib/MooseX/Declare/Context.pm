package MooseX::Declare::Context;

use strict;
use warnings;

use base 'Devel::Declare::Context::Simple';

sub strip_options {
    my ($self) = @_;
    $self->skipspace;

    my %ret;
    my $linestr = $self->get_linestr();

    while (substr($linestr, $self->offset, 1) ne '{') {
        my $key = $self->strip_name;
        if (!defined $key) {
            die 'expected option name';
        }

        if ($key !~ /^(extends|with|is)$/) {
            die "unknown option name '${key}'";
        }

        my $val = $self->strip_name;
        if (!defined $val) {
            die 'expected option value';
        }

        $ret{$key} ||= [];
        push @{ $ret{$key} }, $val;
        $self->skipspace;
        $linestr = $self->get_linestr();

    }

    return { map {
        my $key = $_;
        $key eq 'is'
            ? ($key => { map { ($_ => 1) } @{ $ret{$key} } })
            : ($key => $ret{$key})
    } keys %ret };
}


1;
