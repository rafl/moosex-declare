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
        { class => { const => \&parser },
          role  => { const => \&parser }, },
    );

    {
        no strict 'refs';
        *{ "${caller}::class" } = sub (&) { };
        *{ "${caller}::role" } = sub (&) { };
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

sub strip_options {
    skipspace;

    my %ret;
    my $linestr = Devel::Declare::get_linestr();

    while (substr($linestr, $Offset, 1) ne '{') {
        my $len = Devel::Declare::toke_scan_word($Offset, 0);
        if (!$len) {
            die 'expected option name';
        }

        $linestr = Devel::Declare::get_linestr();
        my $key = substr($linestr, $Offset, $len);
        substr($linestr, $Offset, $len) = '';

        if ($key !~ /^(extends|with|is)$/) {
            die "unknown option name '${key}'";
        }

        Devel::Declare::set_linestr($linestr);

        skipspace;

        $len = Devel::Declare::toke_scan_word($Offset, 1);
        if (!$len) {
            die 'expected option value';
        }

        $linestr = Devel::Declare::get_linestr();
        my $val = substr($linestr, $Offset, $len);
        substr($linestr, $Offset, $len) = '';

        $ret{$key} ||= [];
        push @{ $ret{$key} }, $val;

        Devel::Declare::set_linestr($linestr);

        skipspace;
    }

    return \%ret;
}

sub inject_if_block {
    my $inject = shift;

    skipspace;

    my $linestr = Devel::Declare::get_linestr;
    if (substr($linestr, $Offset, 1) eq '{') {
        substr($linestr, $Offset+1, 0) = $inject;
        Devel::Declare::set_linestr($linestr);
    }
}

sub scope_injector_call {
     return 'BEGIN { MooseX::DefClass::inject_scope }; ';
}

sub shadow {
    my $pack = Devel::Declare::get_curstash_name;
    Devel::Declare::shadow_sub("${pack}::${Declarator}", $_[0]);
}

sub options_unwrap {
    my ($options) = @_;
    my $ret = '';

    if (my $superclasses = $options->{extends}) {
        $ret .= 'extends ';
        $ret .= join q{,}, map { qq{'${_}'} } @{ $superclasses };
        $ret .= ';';
    }

    if (my $roles = $options->{with}) {
        $ret .= 'with ';
        $ret .= join q{,}, map { qq{'${_}'} } @{ $roles };
        $ret .= ';';
    }

    if (my $traits = $options->{is}) {
        for my $trait (@{ $traits }) {
            die "unsupported trait ${trait}";
        }
    }

    return $ret;
}

sub parser {
    local ($Declarator, $Offset) = @_;

    skip_declarator;

    my $name = strip_name;
    my $stash = Devel::Declare::get_curstash_name();
    $name = join('::', Devel::Declare::get_curstash_name(), $name)
        unless $stash eq 'main';

    my $inject = qq/package ${name}; use MooseX::DefClass; /;
    if ($Declarator eq 'class') {
        $inject .= q/use Moose;/;
    }
    elsif ($Declarator eq 'role') {
        $inject .= q/use Moose::Role;/;
    }
    else { die }

    my $options = strip_options;
    $inject .= options_unwrap($options);

    warn $inject;

    if (defined $name) {
        $inject = $inject . scope_injector_call();
    }

    inject_if_block($inject);

    if (defined $name) {
        shadow(sub (&) { shift->() });
    }
    else {
        shadow(sub (&) { die "anon class unsupported" });
    }
}

sub inject_scope {
    $^H |= 0x120000;
    $^H{DD_METHODHANDLERS} = Scope::Guard->new(sub {
        my $linestr = Devel::Declare::get_linestr();
        return unless defined $linestr;
        my $offset  = Devel::Declare::get_linestr_offset();
        substr($linestr, $offset, 0) = ';';
        Devel::Declare::set_linestr($linestr);
    });
}

1;
