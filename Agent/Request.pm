# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Request;
use strict;

$Bivio::Agent::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::Request - Abstract request wrapper

=head1 SYNOPSIS

    use Bivio::Agent::Request;
    Bivio::Agent::Request->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Request::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Request> Request provides a common interface for http,
email, ... requests to the application. It provides methods to access
the club, controller, model, view, and user information. Other action
parameters can be accessed through the get_parameter($name) method.
Request also provides access to the request output stream through the
method print($str).

=cut

=head1 CONSTANTS

Request states:

OK - successful
FORBIDDEN - user not authorized to do request
NOT_HANDLED - request not supported
AUTH_REQUIRED - needs authorization to proceed
SERVER_ERROR - internal error

=cut

sub OK { 0 };
sub FORBIDDEN { 1 };
sub NOT_HANDLED { 2 };
sub AUTH_REQUIRED { 3 };
sub SERVER_ERROR { 4 }

#=IMPORTS
use Bivio::Biz::User;
use Bivio::Util;

#=VARIABLES

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 new(string target_name, string controller_name, string user_name) : Bivio::Agent::Request

Creates a Request using the specified target, controller, and user.
The initial state of the request is NOT_HANDLED. user may be undef,
indicating that no authorization has been performed.

=cut

sub new {
    my($proto, $target_name, $controller_name, $user) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
        target => $target_name,
        controller => $controller_name,
        user => $user,
        reply_type => '',
        state => NOT_HANDLED,
	start_time => Bivio::Util::gettimeofday
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="elapsed_time"></a>

=head2 elapsed_time() : float

Returns the number of seconds elapsed since the request was created.

=cut

sub elapsed_time {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return Bivio::Util::time_delta_in_seconds($fields->{start_time});
}

=for html <a name="get_arg"></a>

=head2 abstract get_arg(string name) : name

Returns the named request argument value.

=cut

sub get_arg {
    die('abstract method called');
}

=for html <a name="get_controller_name"></a>

=head2 get_controller_name() : string

Returns the name of the controller.

=cut

sub get_controller_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{controller};
}

=for html <a name="get_reply_type"></a>

=head2 get_reply_type() : string

Returns the reply format type.

=cut

sub get_reply_type {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{reply_type};
}

=for html <a name="get_state"></a>

=head2 get_state() : int

Returns the state of the request. This should be one of the constant
values described above.

=cut

sub get_state {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{state};
}

=for html <a name="get_target_name"></a>

=head2 get_target_name() : string

Returns the target of the request (ie, user or club name).

=cut

sub get_target_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{target};
}

=for html <a name="get_user"></a>

=head2 get_user() : User

Returns the user. If no user exists (ie. no login has been done, then
undef is returned.

=cut

sub get_user {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{user};
}

=for html <a name="log_error"></a>

=head2 abstract log_error(string message)

Writes the specified message to an error log appropriate for
the request.

=cut

sub log_error {
    die("abstract method");
}

=for html <a name="print"></a>

=head2 abstract print(string str)

Writes the specified string to the request's output stream.

=cut

sub print {
    die("abstract method");
}

=for html <a name="put_arg"></a>

=head2 abstract put_arg(string name, string value)

Adds or updates the argument to the specified value.

=cut

sub put_arg {
    die("abstract method");
}

=for html <a name="set_reply_type"></a>

=head2 set_reply_type(string type)

Sets the reply format type.

=cut

sub set_reply_type {
    my($self, $type) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{reply_type} = $type;
}

=for html <a name="set_state"></a>

=head2 set_state(int state)

Sets the state of the request the specified value. This should be one of the
constant values describe above.

=cut

sub set_state {
    my($self, $state) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{state} = $state;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

my($r) = Bivio::Agent::Request->new();

1;
