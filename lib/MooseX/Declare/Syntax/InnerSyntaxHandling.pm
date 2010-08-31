package MooseX::Declare::Syntax::InnerSyntaxHandling;
# ABSTRACT: Keywords inside blocks

use Moose::Role;

use MooseX::Declare::Util qw( outer_stack_push );

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

This role allows you to setup keyword handlers that are only available
inside blocks or other scoping environments.

=head1 REQUIRED METHODS

=head2 get_identifier

  Str get_identifier ()

Required to return the name of the identifier of the current handler.

=cut

requires qw(
    get_identifier
);

=method default_inner

  ArrayRef[Object] Object->default_inner ()

Returns an empty C<ArrayRef> by default. If you want to setup additional
keywords you will have to C<around> this method.

=cut

sub default_inner { [] }

=head1 MODIFIED METHODS

=head2 setup_for

  Object->setup_for(ClassName $class, %args)

After the keyword is setup inside itself, this will call L</setup_inner_for>.

=cut

after setup_for => sub {
    my ($self, $setup_class, %args) = @_;

    # make sure stack is valid
    my $stack = $args{stack} || [];

    # setup inner keywords if we're inside ourself
    if (grep { $_ eq $self->get_identifier } @$stack) {
        $self->setup_inner_for($setup_class, %args);
    }
};

=method setup_inner_for

  Object->setup_inner_for(ClassName $class, %args)

Sets up all handlers in the inner class.

=cut

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

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::NamespaceHandling>
* L<MooseX::Declare::Syntax::MooseSetup>

=cut

1;
