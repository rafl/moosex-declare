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
