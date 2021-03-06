package socialEvents;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Authentication 
    Session
    Session::State::Cookie
    Session::Store::FastMmap
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in socialevents.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'socialEvents',
	  'View::TT' => {
                         INCLUDE_PATH => [
                             __PACKAGE__->path_to('root', 'src'),
                             __PACKAGE__->path_to('root', 'lib')
                         ],
                         TEMPLATE_EXTENSION => '.tt',
                         CATALYST_VAR       => 'c',
                         TIMER              => 0,
                         PRE_PROCESS        => 'config/main',
                         WRAPPER            => 'site/wrapper'
                     },
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    'Plugin::Authentication' => { 
        default => {
            credential => { class => 'Password', password_type => 'clear'   , password_field => 'pwd'}, 
            store => {
                class => 'DBIx::Class', 
                user_model => 'DB::User', 
                use_userdata_from_session => '1'
            }
        }
    }
    );

__PACKAGE__->config(session => {flash_to_stash => 1});
# Start the application
__PACKAGE__->setup();


=head1 NAME

socialEvents - Catalyst based application

=head1 SYNOPSIS

    script/socialevents_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<socialEvents::Controller::Root>, L<Catalyst>

=head1 AUTHOR

fabiim,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
