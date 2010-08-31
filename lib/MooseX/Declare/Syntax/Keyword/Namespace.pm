package MooseX::Declare::Syntax::Keyword::Namespace;
# ABSTRACT: Declare outer namespace

use Moose;
use Carp qw( confess );

use MooseX::Declare::Util qw( outer_stack_push outer_stack_peek );

use namespace::clean -except => 'meta';

=head1 SYNOPSIS

  use MooseX::Declare;

  namespace Foo::Bar;

  class ::Baz extends ::Qux with ::Fnording {
      ...
  }

=head1 DESCRIPTION

The C<namespace> keyword allows you to declare an outer namespace under
which other namespaced constructs can be nested. The L</SYNOPSIS> is
effectively the same as

  use MooseX::Declare;

  class Foo::Bar::Baz extends Foo::Bar::Qux with Foo::Bar::Fnording {
      ...
  }

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::KeywordHandling>

=cut

with qw(
    MooseX::Declare::Syntax::KeywordHandling
);

=method parse

  Object->parse(Object $context)

Will skip the declarator, parse the namespace and push the namespace
in the file package stack.

=cut

sub parse {
    my ($self, $ctx) = @_;

    confess "Nested namespaces are not supported yet"
        if outer_stack_peek $ctx->caller_file;

    $ctx->skip_declarator;
    my $namespace = $ctx->strip_word
        or confess "Expected a namespace argument to use from here on";

    confess "Relative namespaces are currently not supported"
        if $namespace =~ /^::/;

    $ctx->skipspace;

    my $next_char = $ctx->peek_next_char;
    confess "Expected end of statement after namespace argument"
        unless $next_char eq ';';

    outer_stack_push $ctx->caller_file, $namespace;
}

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>

=cut

1;
