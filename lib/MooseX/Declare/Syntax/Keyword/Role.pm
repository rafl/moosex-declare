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
