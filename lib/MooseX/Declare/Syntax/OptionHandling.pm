package MooseX::Declare::Syntax::OptionHandling;

use Moose::Role;

use Carp qw( croak );

use namespace::clean -except => 'meta';

requires qw( get_identifier );

sub ignored_options { qw( is ) }

after add_optional_customizations => sub {
    my ($self, $ctx, $package, $options) = @_;

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

1;
