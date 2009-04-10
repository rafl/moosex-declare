package MooseX::Declare::Context;

use Moose;
use Carp qw/croak/;

use aliased 'Devel::Declare::Context::Simple', 'DDContext';

use namespace::clean -except => 'meta';

has _dd_context => (
    is          => 'ro',
    isa         => DDContext,
    required    => 1,
    builder     => '_build_dd_context',
    lazy        => 1,
    handles     => qr/.*/,
);

has _dd_init_args => (
    is          => 'rw',
    isa         => 'HashRef',
    default     => sub { {} },
    required    => 1,
);

has caller_file => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);

has preamble_code_parts => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { [] },
);

has scope_code_parts => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { [] },
);

has cleanup_code_parts => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { [] },
);

has stack => (
    is          => 'rw',
    isa         => 'ArrayRef',
    default     => sub { [] },
    required    => 1,
);

sub add_preamble_code_parts {
    my ($self, @parts) = @_;
    push @{ $self->preamble_code_parts }, @parts;
}

sub add_scope_code_parts {
    my ($self, @parts) = @_;
    push @{ $self->scope_code_parts }, @parts;
}

sub add_cleanup_code_parts {
    my ($self, @parts) = @_;
    push @{ $self->cleanup_code_parts }, @parts;
}

sub inject_code_parts_here {
    my ($self, @parts) = @_;

    # get code to inject and rest of line
    my $inject  = $self->_joined_statements(\@parts);
    my $linestr = $self->get_linestr;

    # add code to inject to current line and inject it
    substr($linestr, $self->offset, 0, "$inject");
    $self->set_linestr($linestr);

    return 1;
}

sub peek_next_char {
    my ($self) = @_;

    # return next char in line
    my $linestr = $self->get_linestr;
    return substr $linestr, $self->offset, 1;
}

sub inject_code_parts {
    my ($self, %args) = @_;

    # default to injecting cleanup code
    $args{inject_cleanup_code_parts} = 1
        unless exists $args{inject_cleanup_code_parts};

    # add preamble and scope statements to injected code
    my $inject;
    $inject .= $self->_joined_statements('preamble');
    $inject .= ';' . $self->_joined_statements('scope');

    # if we should also inject the cleanup code
    if ($args{inject_cleanup_code_parts}) {
        $inject .= ';' . $self->scope_injector_call($self->_joined_statements('cleanup'));
    }

    # we have a block
    if ($self->peek_next_char eq '{') {
        $self->inject_if_block("$inject");
    }

    # there was no block to inject into
    else {
        # require end of statement
        croak "block or semi-colon expected after " . $self->declarator . " statement"
            unless $self->peek_next_char eq ';';

        # delegate the processing of the missing block
        $args{missing_block_handler}->($self, $inject, %args);
    }

    return 1;
}

sub _joined_statements {
    my ($self, $section) = @_;

    # if the section was not an array reference, get the
    # section contents of that name
    $section = $self->${\"${section}_code_parts"}
        unless ref $section;

    # join statements via semicolon
    # array references are expected to be in the form [FOO => 1, 2, 3]
    # which would yield BEGIN { 1; 2; 3 }
    return join '; ', map {
        not( ref $_ ) ? $_ : do {
            my ($block, @parts) = @$_;
            sprintf '%s { %s }', $block, join '; ', @parts;
        };
    } @{ $section };
}

sub BUILD {
    my ($self, $attrs) = @_;

    # remember the constructor arguments for the delegated context
    $self->_dd_init_args($attrs);
}

sub _build_dd_context {
    my ($self) = @_;

    # create delegated context with remembered arguments
    return DDContext->new(%{ $self->_dd_init_args });
}

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
            if (defined($val = $self->strip_proto)) {
                $val = [split /\s*,\s*/, $val];
            }
            else {
                croak "expected option value after $key";
            }
        }

        $ret{$key} ||= [];
        push @{ $ret{$key} }, ref $val ? @{ $val } : $val;
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
