# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Request;
use strict;
$Bivio::Agent::HTTP::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::Request - An HTTP Request

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::HTTP::Request::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Request> is a Bivio Request wrapper for an
Apache::Request. It gathers request information from the URI and posted
parameters. The general format is:

bivio.com/<target>/<controller>/<view>
&mf=<arg1>(<val1>),<arg2>(<val2>)...&ma=<action>&...

  where <target> is a person or club
  <controller> is the controller id (messages, accounting, ...)
  <view> is the view id (list, detail, ...)
  <arg1>(<val1>)... are model finder parameters
  <action> is what to do with the model (update, vote, ...)

The rest of the arguments are action parameters.
Much of the URI is optional (requests have default controllers, controllers
have default views).

The 'mf' argument is converted into a Bivio::Biz::FindParams and is available
using the L<"get_model_args">.

=cut

#=IMPORTS
use Apache::Constants;
use Bivio::Biz::FindParams;
use Bivio::Biz::User;
use Bivio::Util;

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r, string default_controller_name) : Bivio::Agent::HTTP::Request

Creates a Request from an apache request. The default controller name
will be used if no controller name can be parsed from the URI.

=cut

sub new {
    my($proto, $r, $default_controller_name) = @_;

    my($start_time) = Bivio::Util::gettimeofday();

    # this is required for the connection->user to work!?
    my($ret, $password) = $r->get_basic_auth_pw();
    my($target, $controller, $view) = _parse_request($r->uri());
    $controller ||= $default_controller_name;

    my(%args) = $r->args;
    my($self) = &Bivio::Agent::Request::new($proto, $target, $controller,
	    &_find_user($r->connection->user), $start_time);
    $self->{$_PACKAGE} = {
        r => $r,
	view_name => $view,
        header_sent => 0,
	args => \%args,
	password => $password,
	model_args => Bivio::Biz::FindParams->from_string($args{mf} || '')
    };
    delete($args{mf});

    #default to html
    $self->set_reply_type('text/html');

    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_action_name"></a>

=head2 get_action_name() : string

Returns the requested action.

=cut

sub get_action_name {
    my($self) = @_;
    return $self->get_arg('ma');
}

=for html <a name="get_arg"></a>

=head2 get_arg(string name) : string

Returns the named request argument value from the inquiry or posted
parameters.

=cut

sub get_arg {
    my($self,$name) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{args}->{$name};
}

=for html <a name="get_http_return_code"></a>

=head2 get_http_return_code() : int

Returns the appropriate Apache::Constant depending on the current state
of the request.

=cut

sub get_http_return_code {
    my($self) = @_;
    my($state) = $self->get_state();

    # need to translate from Request state to Apache rc
    return Apache::Constants::AUTH_REQUIRED
	    if $state == Bivio::Agent::Request::AUTH_REQUIRED;
    return Apache::Constants::FORBIDDEN
	    if $state == Bivio::Agent::Request::FORBIDDEN;
    return Apache::Constants::NOT_FOUND
	    if $state == Bivio::Agent::Request::NOT_HANDLED;
    return Apache::Constants::OK
	    if $state == Bivio::Agent::Request::OK;
    return Apache::Constants::SERVER_ERROR
	    if $state == Bivio::Agent::Request::SERVER_ERROR;

    die("invalid request state $state");
}

=for html <a name="get_model_args"></a>

=head2 get_model_args() : Bivio::Biz::FindParams

Returns the model finder arguments. Created from the 'mf' argument.
If no arguments are present, then an empty FindParams is returned.
see L<Bivio::Biz::FindParams>.

=cut

sub get_model_args {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{model_args};
}

=for html <a name="get_password"></a>

=head2 get_password() : string

Returns the password from user authentication.

=cut

sub get_password {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{password};
}

=for html <a name="get_view_name"></a>

=head2 get_view_name() : string

Returns the requested view name.

=cut

sub get_view_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{view_name};
}

=for html <a name="log_error"></a>

=head2 log_error(string message)

Writes the specified message to the apache error log.

=cut

sub log_error {
    my($self, $message) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{r}->log_error($message);
}

=for html <a name="print"></a>

=head2 print(string str)

Writes the specified string to the request's output stream.

=cut

sub print {
    my($self,$str) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($fields->{header_sent} == 0) {
	# only do this on first print
	$fields->{header_sent} = 1;

	$fields->{r}->content_type($self->get_reply_type());
	$fields->{r}->send_http_header;
    }
    $fields->{r}->print($str || 'undef');
}

=for html <a name="put_arg"></a>

=head2 put_arg(string name, string value)

Adds or replaces the named argument.

=cut

sub put_arg {
    my($self, $name, $value) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{args}->{$name} = $value;
}

=for html <a name="set_args"></a>

=head2 set_args(hash args)

Sets the request arguments to the specified hash. All previous arguments
will be lost.

=cut

sub set_args {
    my($self, $args) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{args} = $args;
}

=for html <a name="set_view_name"></a>

=head2 set_view_name(string name)

Redirects the requests view to the specified one.

=cut

sub set_view_name {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{view_name} = $name;
}

#=PRIVATE METHODS

# _find_user(string name) : User
#
# Attempts to find a user with the specified login id. Returns undef if
# no user exists for that login.

sub _find_user {
    my($name) = @_;

    return undef if ! $name;

    my($user) = Bivio::Biz::User->new();
    return $user->find(Bivio::Biz::FindParams->new({name => $name}))
	    ? $user : undef;
}

# _parse_request(string uri) : (string, string, view)
#
# Takes a URI request and parses the target, controller, and view
#
# input format: /<target>[/<controller>[/view][/]]
#
sub _parse_request {
    my($str) = @_;

    # trim leading and trailing '/'
    $str =~ s,^/|/$,,g;

    my(@parts) = split('/', $str);

    my($target) = $parts[0];
    my($controller) = $parts[1] || '';
    my($view) = $parts[2] || '';

    return ($target, $controller, $view);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
