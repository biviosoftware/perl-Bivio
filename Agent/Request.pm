# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Request;
use strict;

$Bivio::Agent::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Request - Abstract request wrapper

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Request::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Request> Request provides a common interface for http,
email, ... requests to the application. It provides methods to access
the controller name and user information. Action arguments can be accessed
through the L<"get_arg"> method. Requests provide access to a
L<Bivio::Agent::Reply|"Bivio::Agent::Reply"> using the
L<get_reply|"get_reply"> method.

=cut

#=IMPORTS
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 new(string target_name, string controller_name, Bivio::Biz::User user, float start_time) : Bivio::Agent::Request

Creates a Request using the specified target, controller, and user.
The initial state of the request is NOT_HANDLED. user may be undef,
indicating that no authorization has been performed. start_time should
be the time when the request is first constructed.

=cut

sub new {
    my($proto, $target_name, $controller_name, $user, $start_time) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
        'target' => $target_name,
        'controller' => $controller_name,
        'user' => $user,
	'start_time' => $start_time
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

=for html <a name="get_reply"></a>

=head2 abstract get_reply() : Bivio::Agent::Reply

Returns the L<Bivio::Agent::Reply|"Bivio::Agent::Reply"> subclass for this
particular instance.

=cut

sub get_reply {
    die("abstract method");
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

=head2 get_user() : Bivio::Biz::User

Returns the L<Bivio::Biz::User>. If no user exists (ie. no login has been
performed, then undef is returned.

=cut

sub get_user {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{user};
}

=for html <a name="put_arg"></a>

=head2 abstract put_arg(string name, string value)

Adds or replaces the named arguments value.

=cut

sub put_arg {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
