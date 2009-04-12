package MooseX::Declare::Syntax::InnerSyntaxHandling;

use Moose::Role;

use MooseX::Declare::Util qw( outer_stack_push );

use namespace::clean -except => 'meta';

requires qw(
    get_identifier
);

has inner => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    builder     => 'default_inner',
    lazy        => 1,
);

sub default_inner { [] }

after setup_for => sub {
    my ($self, $setup_class, %args) = @_;

    # make sure stack is valid
    my $stack = $args{stack} || [];

    # setup inner keywords if we're inside ourself
    if (grep { $_ eq $self->get_identifier } @$stack) {

        $self->setup_inner_for($setup_class, %args);
    }
};

sub setup_inner_for {
    my ($self, $setup_class, %args) = @_;

    # setup each keyword in target class
    for my $inner (@{ $self->inner }) {
        $inner->setup_for($setup_class, %args);
    }

    # push package onto stack for namespace management
    if (exists $args{file}) {
        outer_stack_push $args{file}, $args{outer_package};
    }
}

1;
