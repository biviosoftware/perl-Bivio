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
L<Bivio::Agent::Reply> using the L<get_reply|"get_reply"> method.

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register({
	'host' => `hostname`
    });
my($_HOST_NAME);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 new(string target_name, string controller_name, float start_time) : Bivio::Agent::Request

Creates a Request using the specified target and controller.
The initial state of the request is NOT_HANDLED. user may be undef,
indicating that no authorization has been performed. start_time should
be the time when the request is first constructed. Requests have a
'context' for storing and retrieving arbitrary values during processing.
Context values are accessed using L<"get"> and L<"put">.

By default, only the 'host' context entry will be present, which represents
the application server's host name.

=cut

sub new {
    my($proto, $target_name, $controller_name, $start_time) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
        'target' => $target_name,
        'controller' => $controller_name,
	'start_time' => $start_time,
	'context' => {}
    };
    $self->put('host', $_HOST_NAME);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="configure"></a>

=head2 static configure(hash cfg)

Host name configuration. Override this to proxy to another host.

=over 4

=item host : string [`hostname`]

=back

=cut

sub configure {
    my(undef, $cfg) = @_;
    $_HOST_NAME = $cfg->{host};
    return;
}

=for html <a name="delete"></a>

=head2 delete(string name)

Removes the named attribute from the Request's context.

=cut

sub delete {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    die("attribute $name doesn't in context")
	    if ! exists($fields->{context}->{$name});
    delete($fields->{context}->{$name});
    return;
}

=for html <a name="elapsed_time"></a>

=head2 elapsed_time() : float

Returns the number of seconds elapsed since the request was created.

=cut

sub elapsed_time {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return Bivio::Util::time_delta_in_seconds($fields->{start_time});
}

=for html <a name="exists"></a>

=head2 exists(string name) : boolean

Returns 1 if the named values exists in the Request's context,
0 otherwise.

=cut

sub exists {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return exists($fields->{context}->{$name}) ? 1 : 0;
}

=for html <a name="get"></a>

=head2 get(string name) : any

Returns the named attribute from the Request's 'context'. See L<"put">.

=cut

sub get {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    die("attribute $name doesn't in context")
	    if ! exists($fields->{context}->{$name});
    return $fields->{context}->{$name};
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

=for html <a name="put"></a>

=head2 put(string name, any value)

Puts the named value into the Request's context. See L<"get">. This will
overwrite an existing context value with the same name.

=cut

sub put {
    my($self, $name, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{context}->{$name} = $value;
    return;
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
