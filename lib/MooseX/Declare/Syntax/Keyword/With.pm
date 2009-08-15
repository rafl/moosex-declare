package MooseX::Declare::Syntax::Keyword::With;

use Moose;
use Moose::Util;
use MooseX::Declare::Util qw( outer_stack_peek );
use aliased 'MooseX::Declare::Context::Namespaced';
use namespace::autoclean;

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

around context_traits => sub { shift->(@_), Namespaced };

sub parse {
    my ($self, $ctx) = @_;

    $ctx->skip_declarator;

    my $pkg = outer_stack_peek $ctx->caller_file;
    $ctx->shadow(sub {
        Moose::Util::apply_all_roles($pkg, map {
            $ctx->qualify_namespace($_)
        } @_);
    });
}

1;

=head1 NAME

MooseX::Declare::Syntax::Keyword::With - Apply roles within a class- or role-body

=head1 SYNOPSIS

  use MooseX::Declare;

  class ::Baz {
      with 'Qux';
      ...
  }

=head1 DESCRIPTION

The C<with> keyword allows you to apply roles to the local class or role. It
differs from the C<with>-option of the C<class> and C<role> keywords in that it
applies the roles immediately instead of defering application until the end of
the class- or role-definition.

It also differs slightly from the C<with> provided by L<Moose|Moose> in that it
expands relative role names (C<::Foo>) according to the currenc C<namespace>.

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::KeywordHandling>

=back

=head1 METHODS

=head2 parse

  Object->parse(Object $context)

Will skip the declarator and make with C<with> invocation apply the set of
specified roles after possible C<namespace>-expanding has been done.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::Keyword::Namespace>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
