use strict;
use warnings;

package MooseX::DefClass;

use Scope::Guard;
use Devel::Declare ();

our $VERSION = '0.01_01';

our ($Declarator, $Offset);

sub import {
    my $caller = caller();

    Devel::Declare->setup_for(
        $caller,
        { class => { const => \&parser } },
    );

    {
        no strict 'refs';
        *{ "${caller}::class" } = sub (&) {};
    }
}

sub skip_declarator {
    $Offset += Devel::Declare::toke_move_past_token($Offset);
}

sub skipspace {
    $Offset += Devel::Declare::toke_skipspace($Offset);
}

sub strip_name {
    skipspace;

    if (my $len = Devel::Declare::toke_scan_word($Offset, 1)) {
        my $linestr = Devel::Declare::get_linestr();
        my $name    = substr($linestr, $Offset, $len);
        substr($linestr, $Offset, $len) = '';
        Devel::Declare::set_linestr($linestr);
        return $name;
    }

    skipspace;

    return;
}

sub inject_if_block {
    my $inject = shift;

    skipspace;

    my $linestr = Devel::Declare::get_linestr;
    if (substr($linestr, $Offset, 1) eq '{') {
        substr($linestr, $Offset+1, 0) = $inject;
        Devel::Declare::set_linestr($linestr);
        warn Devel::Declare::get_linestr();
    }
}

sub scope_injector_call {
     return ' BEGIN { MooseX::DefClass::inject_scope }; ';
}

sub parser {
    local ($Declarator, $Offset) = @_;

    skip_declarator;

    my $name = strip_name;

    my $inject = "package ${name}; use Moose;";

    if (defined $name) {
        $inject = scope_injector_call() . $inject;
    }

    print STDERR $inject, "\n";

    inject_if_block($inject);
}

sub inject_scope {
    $^H |= 0x120000;
    $^H{DD_METHODHANDLERS} = Scope::Guard->new(sub {
        my $linestr = Devel::Declare::get_linestr;
        my $offset  = Devel::Declare::get_linestr_offset;
        substr($linestr, $offset, 0) = ';';
        Devel::Declare::set_linestr($linestr);
    });
}

1;
