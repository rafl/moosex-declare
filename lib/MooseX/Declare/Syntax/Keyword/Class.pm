package MooseX::Declare::Syntax::Keyword::Class;
# ABSTRACT: Class declarations

use Moose;

use namespace::clean -except => 'meta';

=head1 CONSUMES

=for :list
* L<MooseX::Declare::Syntax::MooseSetup>
* L<MooseX::Declare::Syntax::RoleApplication>
* L<MooseX::Declare::Syntax::Extending>

=cut

with qw(
    MooseX::Declare::Syntax::MooseSetup
    MooseX::Declare::Syntax::RoleApplication
    MooseX::Declare::Syntax::Extending
);

=head1 MODIFIED METHODS

=head2 imported_moose_symbols

  List Object->imported_moose_symbols ()

Extends the existing L<MooseX::Declare::Syntax::MooseSetup/imported_moose_symbols>
with C<extends>, C<has>, C<inner> and C<super>.

=cut

around imported_moose_symbols => sub { shift->(@_), qw( extends has inner super ) };

=method generate_export

  CodeRef generate_export ()

This will return a closure doing a call to L</make_anon_metaclass>.

=cut

sub generate_export { my $self = shift; sub { $self->make_anon_metaclass } }


=head2 auto_make_immutable

  Bool Object->auto_make_immutable ()

Is set to a true value, so classes are made immutable by default.

=cut

around auto_make_immutable => sub { 1 };

=head2 make_anon_metaclass

  Object Object->make_anon_metaclass ()

Returns an anonymous instance of L<Moose::Meta::Class>.

=cut

around make_anon_metaclass => sub { Moose::Meta::Class->create_anon_class };

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::Keyword::Role>
* L<MooseX::Declare::Syntax::RoleApplication>
* L<MooseX::Declare::Syntax::Extending>
* L<MooseX::Declare::Syntax::MooseSetup>

=cut

1;
