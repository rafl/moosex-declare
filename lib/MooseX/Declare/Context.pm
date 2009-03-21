package MooseX::Declare::Context;

use strict;
use warnings;
use Carp qw/croak/;

use base 'Devel::Declare::Context::Simple';

sub strip_name_and_options {
    my ($self) = @_;
    $self->skipspace;

    # Make errors get reported from right place in source file
    local $Carp::Internal{'MooseX::Declare'} = 1;
    local $Carp::Internal{'Devel::Declare'} = 1;

    my ($name, %ret);
    my $linestr = $self->get_linestr();

    while (substr($linestr, $self->offset, 1) !~ /[{;]/) {
        my $key = $self->strip_name;
        if (!defined $key) {

            croak 'expected option name'
              if keys %ret;
            return; # This is the case when { class => 'foo' } happens
        }

        if ($key !~ /^(extends|with|is)$/) {
            unless (keys %ret) {
              $name = $key;
              $self->skipspace;
              $linestr = $self->get_linestr();
              next;
            }
            croak "unknown option name '$key'";
        }

        my $val = $self->strip_name;
        if (!defined $val) {
            croak "expected option value after $key";
        }

        $ret{$key} ||= [];
        push @{ $ret{$key} }, $val;
        $self->skipspace;
        $linestr = $self->get_linestr();
    }

    return ($name, { map {
        my $key = $_;
        $key eq 'is'
            ? ($key => { map { ($_ => 1) } @{ $ret{$key} } })
            : ($key => $ret{$key})
    } keys %ret } );
}


1;
