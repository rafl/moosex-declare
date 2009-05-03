package MooseX::Declare::Syntax::Keyword::Class;

use Moose;

use namespace::clean -except => 'meta';

with qw(
    MooseX::Declare::Syntax::MooseSetup
    MooseX::Declare::Syntax::RoleApplication
    MooseX::Declare::Syntax::Extending
);

around imported_moose_symbols => sub { shift->(@_), qw( extends has inner super ) };

sub generate_export { my $self = shift; sub { $self->make_anon_metaclass } }

around auto_make_immutable => sub { 1 };

around make_anon_metaclass => sub { Moose::Meta::Class->create_anon_class };

1;

__END__

=head1 NAME

MooseX::Declare::Syntax::Keyword::Class - Class declarations

=head1 CONSUMES

=over

=item * L<MooseX::Declare::Syntax::MooseSetup>

=item * L<MooseX::Declare::Syntax::RoleApplication>

=item * L<MooseX::Declare::Syntax::Extending>

=back

=head1 METHODS

=head2 generate_export

  CodeRef generate_export ()

This will return a closure doing a call to L</make_anon_metaclass>.

=head1 MODIFIED METHODS

=head2 imported_moose_symbols

  List Object->imported_moose_symbols ()

Extends the existing L<MooseX::Declare::Syntax::MooseSetup/imported_moose_symbols>
with C<extends>, C<has>, C<inner> and C<super>.

=head2 auto_make_immutable

  Bool Object->auto_make_immutable ()

Is set to a true value, so classes are made immutable by default.

=head2 make_anon_metaclass

  Object Object->make_anon_metaclass ()

Returns an anonymous instance of L<Moose::Meta::Class>.

=head1 SEE ALSO

=over

=item * L<MooseX::Declare>

=item * L<MooseX::Declare::Syntax::Keyword::Role>

=item * L<MooseX::Declare::Syntax::RoleApplication>

=item * L<MooseX::Declare::Syntax::Extending>

=item * L<MooseX::Declare::Syntax::MooseSetup>

=back

=head1 AUTHOR, COPYRIGHT & LICENSE

See L<MooseX::Declare>

=cut
