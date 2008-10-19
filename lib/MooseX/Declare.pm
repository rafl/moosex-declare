use strict;
use warnings;

package MooseX::Declare;

use Devel::Declare ();
use Moose::Meta::Class;
use B::Hooks::EndOfScope;
use MooseX::Method::Signatures;

our $VERSION = '0.01_01';

our ($Declarator, $Offset, @Roles);

sub import {
    my ($class, $type) = @_;
    $type ||= '';

    my $caller = caller();

    my @blocks    = qw/class role/;
    my @modifiers = qw/before after around override augment/;

    my @exported = @blocks;

    Devel::Declare->setup_for($caller => {
        (map { $_ => { const => \&class_parser } } @blocks),
    });

    if (defined $type && $type eq 'inner') {
        Devel::Declare->setup_for($caller => {
            (map { $_ => { const => \&modifier_parser } } @modifiers),
        });

        push @exported, @modifiers;
    }

    {
        no strict 'refs';
        *{ "${caller}::${_}" } = sub (&) { }
            for @exported;

        *{ "${caller}::with" } = sub { push @Roles, @_; }
            if $type eq 'inner';
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

sub strip_proto {
    skipspace;

    my $linestr = Devel::Declare::get_linestr();
    if (substr($linestr, $Offset, 1) eq '(') {
        my $length = Devel::Declare::toke_scan_str($Offset);
        my $proto  = Devel::Declare::get_lex_stuff();
        Devel::Declare::clear_lex_stuff();
        $linestr = Devel::Declare::get_linestr();
        substr($linestr, $Offset, $length) = '';
        Devel::Declare::set_linestr($linestr);
        return $proto;
    }

    return;
}

sub inject_if_block {
    my $inject = shift;
    my $inject_before = shift || '';

    skipspace;

    my $linestr = Devel::Declare::get_linestr;
    if (substr($linestr, $Offset, 1) eq '{') {
        substr($linestr, $Offset+1, 0) = $inject;
        substr($linestr, $Offset, 0) = $inject_before;
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

    my $proto = strip_proto || '';

    $proto = '$orig: $self' . (length $proto ? ", ${proto}" : '')
        if $Declarator eq 'around';

    inject_if_block( scope_injector_call('};'), "{ method (${proto})" );

    my $meth = Moose->can($Declarator);
    shadow(sub (&) {
        my $class = caller();
        $meth->($class, $name, shift->()->body);
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

    my $inject = qq/package ${package}; use MooseX::Declare 'inner'; /;
    my $inject_after = '';

    if ($Declarator eq 'class') {
        $inject       .= q/use Moose qw{extends has inner super confess blessed};/;
        $inject_after .= "${package}->meta->make_immutable;"
            unless exists $options->{is}->{mutable};
    }
    elsif ($Declarator eq 'role') {
        $inject .= q/use Moose::Role qw{requires excludes has extends super inner confess blessed};/;
    }
    else { die }

    $inject .= 'use namespace::clean -except => [qw/meta/];';
    $inject .= options_unwrap($options);

    if (defined $name) {
        $inject .= scope_injector_call($inject_after);
    }

    inject_if_block($inject);

    my $create_class = sub {
        local @Roles = ();
        shift->();
        Moose->can('with')->($package, @Roles)
            if @Roles;
    };

    if (defined $name) {
        shadow(sub (&) { $create_class->(@_); return $name; });
    }
    else {
        shadow(sub (&) { $create_class->(@_); return $anon; });
    }
}

sub inject_scope {
    my ($inject) = @_;

    on_scope_end {
        my $linestr = Devel::Declare::get_linestr();
        return unless defined $linestr;
        my $offset  = Devel::Declare::get_linestr_offset();
        substr($linestr, $offset, 0) = ';' . $inject;
        Devel::Declare::set_linestr($linestr);
    };
}

1;

__END__

=head1 NAME

MooseX::Declare - Declarative syntax for Moose

=head1 SYNOPSIS

    use MooseX::Declare;

    class BankAccount {
        has 'balance' => ( isa => 'Num', is => 'rw', default => 0 );

        method deposit ($amount) {
            $self->balance( $self->balance + $amount );
        }

        method withdraw ($amount) {
            my $current_balance = $self->balance();
            ( $current_balance >= $amount )
                || die "Account overdrawn";
                # TODO: make confess available in methods
            $self->balance( $current_balance - $amount );
        }
    }

    class CheckingAccount extends BankAccount {
        has 'overdraft_account' => ( isa => 'BankAccount', is => 'rw' );

        before withdraw ($amount) {
            my $overdraft_amount = $amount - $self->balance();
            if ( $self->overdraft_account && $overdraft_amount > 0 ) {
                $self->overdraft_account->withdraw($overdraft_amount);
                $self->deposit($overdraft_amount);
            }
        }
    }

=head1 AUTHOR

Florian Ragwitz E<lt>rafl@debian.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008  Florian Ragwitz

Licensed under the same terms as perl itself.

=cut
