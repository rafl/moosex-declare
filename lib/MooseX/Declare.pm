use strict;
use warnings;

package MooseX::Declare;

use Scope::Guard;
use Devel::Declare ();
use Moose::Meta::Class;
use MooseX::Method::Signatures;

our $VERSION = '0.01_01';

our ($Declarator, $Offset);

sub import {
    my $caller = caller();

    Devel::Declare->setup_for($caller => {
        (map { $_ => { const => \&class_parser    } } qw/class role/),
        (map { $_ => { const => \&modifier_parser } } qw/before after around/),
    });

    {
        no strict 'refs';
        *{ "${caller}::${_}" } = sub (&) { }
            for qw/class role/;
        *{ "${caller}::${_}" } = sub (&) { }
            for qw/before after around/;
    }

    MooseX::Method::Signatures->setup_for($caller)
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

    return { map {
        my $key = $_;
        $key eq 'is'
            ? ($key => { map { ($_ => 1) } @{ $ret{$key} } })
            : ($key => $ret{$key})
    } keys %ret };
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
    my ($inject) = @_;
    $inject ||= '';

    return "BEGIN { MooseX::Declare::inject_scope('${inject}') }; ";
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

    return $ret;
}

sub modifier_parser {
    local ($Declarator, $Offset) = @_;

    skip_declarator;

    my $name = strip_name;
    die 'method name expected'
        unless defined $name;

    inject_if_block( scope_injector_call() );

    my $modifier_name = $Declarator;
    shadow(sub (&) {
        my $class = caller();
        Moose::Util::add_method_modifier($class, $modifier_name, [$name => shift]);
    });
}

sub class_parser {
    local ($Declarator, $Offset) = @_;

    skip_declarator;

    my $name    = strip_name;
    my $options = strip_options;

    my ($package, $anon);

    if (defined $name) {
        $package = $name;
        my $stash = Devel::Declare::get_curstash_name();
        $package = join('::', $stash, $name)
            unless $stash eq 'main';
    }
    else {
        $anon = Moose::Meta::Class->create_anon_class;
        $package = $anon->name;
    }

    my $inject = qq/package ${package}; use MooseX::Declare; /;
    my $inject_after = '';

    if ($Declarator eq 'class') {
        $inject       .= q/use Moose qw{extends with has override augment make_immutable};/;
        $inject_after .= "${package}->meta->make_immutable;"
            unless exists $options->{is}->{mutable};
    }
    elsif ($Declarator eq 'role') {
        $inject .= q/use Moose::Role qw{with requires excludes has override make_immutable};/;
    }
    else { die }

    $inject .= 'use namespace::clean -except => [qw/meta/];';
    $inject .= options_unwrap($options);

    if (defined $name) {
        $inject .= scope_injector_call($inject_after);
    }

    inject_if_block($inject);

    if (defined $name) {
        shadow(sub (&) { shift->(); return $name; });
    }
    else {
        shadow(sub (&) { shift->(); return $anon; });
    }
}

sub inject_scope {
    my ($inject) = @_;

    $^H |= 0x120000;
    $^H{MX_DECLARE_SCOPING} = Scope::Guard->new(sub {
        my $linestr = Devel::Declare::get_linestr();
        return unless defined $linestr;
        my $offset  = Devel::Declare::get_linestr_offset();
        substr($linestr, $offset, 0) = ';' . $inject;
        Devel::Declare::set_linestr($linestr);
    });
}

1;

__END__

=head1 NAME

MooseX::Declare - Declarative syntax for Moose

=head1 SYNOPSIS

    class Foo {
        has 'x' => (
            is  => 'ro',
            isa => 'Str',
        );

        method bar ($moo, $kooh) { ... }
    }

=head1 AUTHOR

Florian Ragwitz E<lt>rafl@debian.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008  Florian Ragwitz

Licensed under the same terms as perl itself.

=cut
