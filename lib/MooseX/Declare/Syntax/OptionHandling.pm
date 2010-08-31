package MooseX::Declare::Syntax::OptionHandling;
# ABSTRACT: Option parser dispatching

use Moose::Role;

use Carp qw( croak );

use namespace::clean -except => 'meta';

=head1 DESCRIPTION

This role will call a C<add_foo_option_customization> for every C<foo> option
that is discovered.

=head1 REQUIRED METHODS

=head2 get_identifier

  Str Object->get_identifier ()

This must return the name of the current keyword's identifier.

=cut

requires qw( get_identifier );

=method ignored_options

  List[Str] Object->ignored_options ()

This method returns a list of option names that won't be dispatched. By default
this only contains the C<is> option.

=cut

sub ignored_options { qw( is ) }


=head1 MODIFIED METHODS

=head2 add_optional_customizations

  Object->add_optional_customizations (Object $context, Str $package, HashRef $options)

This will dispatch to the respective C<add_*_option_customization> method for option
handling unless the option is listed in the L</ignored_options>.

=cut

after add_optional_customizations => sub {
    my ($self, $ctx, $package) = @_;
    my $options = $ctx->options;

    # ignored options
    my %ignored = map { ($_ => 1) } $self->ignored_options;

    # try to find a handler for each option
    for my $option (keys %$options) {
        next if $ignored{ $option };

        # call the handler with its own value and all options
        if (my $method = $self->can("add_${option}_option_customizations")) {
            $self->$method($ctx, $package, $options->{ $option }, $options);
        }

        # no handler method was found
        else {
            croak sprintf q/The '%s' keyword does not know what to do with an '%s' option/,
                $self->get_identifier,
                $option;
        }
    }

    return 1;
};

=head1 SEE ALSO

=for :list
* L<MooseX::Declare>
* L<MooseX::Declare::Syntax::NamespaceHandling>

=cut

1;
