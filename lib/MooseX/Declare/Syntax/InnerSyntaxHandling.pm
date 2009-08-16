package MooseX::Declare::Syntax::InnerSyntaxHandling;

use Moose::Role;

use MooseX::Declare::Util qw( outer_stack_push );

use namespace::clean -except => 'meta';

requires qw(
    get_identifier
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
    for my $inner (@{ $self->default_inner($args{stack}) }) {
        $inner->setup_for($setup_class, %args);
    }

    # push package onto stack for namespace management
    if (exists $args{file}) {
        outer_stack_push $args{file}, $args{outer_package};
    }
}

1;

=head1 NAME

MooseX::Declare::Syntax::InnerSyntaxHandling - Keywords inside blocks

=head1 DESCRIPTION

This role allows you to setup keyword handlers that are only available
inside blocks or other scoping environments.

=head1 ATTRIBUTES

=head2 inner

An C<ArrayRef> of keyword handlers that will be setup inside the built
scope. It is initialized by the L</default_inner> method.

=head1 REQUIRED METHODS

=head2 get_identifier

  Str get_identifier ()

Required to return the name of the identifier of the current handler.

=head1 METHODS

=head2 default_inner

  ArrayRef[Object] Object->default_inner ()

Returns an empty C<ArrayRef> by default. If you want to setup additional
keywords you will have to C<around> this method.

=head2 setup_inner_for

  Object->setup_inner_for(ClassName $class, %args)

Sets up all handlers in the L</inner> attribute.

=head1 MODIFIED METHODS

=head2 setup_for

  Object->setup_for(ClassName $class, %args)

After the keyword is setup inside itself, this will call L</setup_inner_for>.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::NamespaceHandling>

=item * L<MooseX::Declare::Syntax::MooseSetup>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
