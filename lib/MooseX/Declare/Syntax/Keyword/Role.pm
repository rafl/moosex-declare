package MooseX::Declare::Syntax::Keyword::Role;

use Moose;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::MooseSetup
    MooseX::Declare::Syntax::RoleApplication
);

around imported_moose_symbols => sub { shift->(@_), qw( requires excludes extends has inner super ) };

around import_symbols_from => sub { 'Moose::Role' };

around make_anon_metaclass => sub { Moose::Meta::Role->create_anon_role };

sub generate_export { my $self = shift; sub { $self->make_anon_metaclass } }

1;

=head1 NAME

MooseX::Declare::Syntax::Keyword::Role - Role declarations

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::MooseSetup>

=item * L<MooseX::Declare::Syntax::RoleApplication>

=back

=head1 METHODS

=head2 generate_export

  CodeRef Object->generate_export ()

Returns a closure with a call to L</make_anon_metaclass>.

=head1 MODIFIED METHODS

=head2 imported_moose_symbols

  List Object->imported_moose_symbols ()

Extends the existing L<MooseX::Declare::Syntax::MooseSetup/imported_moose_symbols>
with C<requires>, C<extends>, C<has>, C<inner> and C<super>.

=head2 import_symbols_from

  Str Object->import_symbols_from ()

Will return L<Moose::Role> instead of the default L<Moose>.

=head2 make_anon_metaclass

  Object Object->make_anon_metaclass ()

This will return an anonymous instance of L<Moose::Meta::Role>.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::Keyword::Class>

=item * L<MooseX::Declare::Syntax::RoleApplication>

=item * L<MooseX::Declare::Syntax::MooseSetup>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
