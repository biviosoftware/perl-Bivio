# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Request;
use strict;

$Bivio::Agent::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Request - Abstract request wrapper

=cut

use Bivio::Type::Attributes;
@Bivio::Agent::Request::ISA = ('Bivio::Type::Attributes');

=head1 DESCRIPTION

C<Bivio::Agent::Request> Request provides a common interface for http,
email, ... requests to the application.  The transport specific
Request implementation initializes most of these values

The Attributes are defined:

=over 4

=item auth_realm : Bivio::Biz::Model

The realm in which the request operates, e.g. a club or a user.

=time auth_role : Bivio::Auth::Role

Role I<auth_user> is allowed to play in I<auth_realm>.
Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.

=time auth_owner_id : int

Value of C<auth_realm->get('owner')->get(I<auth_owner_id_field>)>.
Only valid if I<auth_realm> has an owner.

=time auth_owner_id_field : string

Name of primary key field in I<auth_owner>.
Only valid if I<auth_realm> has an owner.

=time auth_user : Bivio::Biz::PropertyModel::User

The user authenticated with the request

=item form : hash_ref

Attributes in url-encoded POST body or other agent equivalent.
Is C<undef>, if method was not POST or equivalent.
NOTE: Forms must always have unique value names--still ok to
use C<exists> or C<defined>.

=item mailhost : string

Host name to be used in mailto URLs and such.

=item message : Bivio::Mail::Incoming

Mail message represented by this request.

=item query : hash_ref

Attributes in URI query string or other agent equivalent.
Is C<undef>, if there are no query args--still ok to
use C<exists> or C<defined>.

NOTE: Query strings must always have unique value names.

=item reply : Bivio::Agent::Reply

L<Bivio::Agent::Reply|Bivio::Agent::Reply> for this request.

=item start_time : float

The time the request started as a floating point number.
See L<Bivio::Util::gettimeofday|Bivio::Util/"gettimeofday">.

=item task : Bivio::Agent::Task

Tuple containing the Action and View to be executed.
Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.

=item task_id : Bivio::Agent::TaskId

Identifier used to find I<task>.

=item E<lt>ModuleE<gt> : Bivio::UNIVERSAL

Maps I<E<lt>ModuleE<gt>> to an instance of that modules.  Actions
and Views will put instances as they are initialized on to the request.
If there is an owner to the I<auth_realm>, this will be the first
L<Bivio::Biz::Model|Bivio::Biz::Model> added to the request.

=back

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::Die;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_HTTP_HOST) = sprintf('%d.%d.%d.%d',
	unpack('C4', (gethostbyname(substr(`hostname`, 0, -1)))[4]));
my($_MAIL_HOST) = "[$_HTTP_HOST]";
Bivio::IO::Config->register({
    'mail_host' =>  $_MAIL_HOST,
    'http_host' =>  $_HTTP_HOST,
});
my($_CURRENT);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::Agent::Request

Creates a request with initial I<attributes>.  I<http_host> and I<mail_host>
will be set as well, but may be overriden by subclass.

=cut

sub new {
    my($proto, $hash) = @_;
    my($self) = &Bivio::Type::Attributes::new($proto, $hash);
    $self->put('http_host', $_HTTP_HOST);
    $self->put('mail_host', $_MAIL_HOST);
    return $_CURRENT = $self;
}

=head1 METHODS

=cut

=for html <a name="clear_current"></a>

=head2 clear_current()

Clears the state of the current request.  See L<get_current|"get_current">.

=cut

sub clear_current {
    # This breaks any circular references, so AGC can work
    defined($_CURRENT) && $_CURRENT->delete_all;
    $_CURRENT = undef;
    return;
}

=for html <a name="die"></a>

=head2 die(Bivio::Type::Enum code, hash_ref attrs)

Terminate the request with a specific code.

=cut

sub die {
    my($self, $code, $attrs) = @_;
    $attrs || ($attrs = {});
    ref($attrs) eq 'HASH' || ($attrs = {attrs => $attrs});
    $attrs->{request} = $self;
    Bivio::Die->die($code, $attrs, caller);
}

=for html <a name="elapsed_time"></a>

=head2 elapsed_time() : float

Returns the number of seconds elapsed since the request was created.

=cut

sub elapsed_time {
    my($self) = @_;
    return Bivio::Util::time_delta_in_seconds($self->get('start_time'));
}

=for html <a name="format_email"></a>

=head2 format_email(string email) : string

Formats the email address for inclusion in a mail header.
If the host is missing, adds mail_host.

=cut

sub format_email {
    my($self, $email) = @_;
#TODO: Properly quote the email name???
#Cache this?  Will bomb if no auth_realm, owner, or name.
    $email = $self->get('auth_realm')->get('owner_name')
	    unless defined($email);
    $email .= '@' . $self->get('mail_host')
	    unless $email =~ /\@/;
    return $email;
}

=for html <a name="format_http"></a>

=head2 format_http(Bivio::Agent::TaskId task_id, hash_ref query) : string

Creates an http URI.  If I<query> is C<undef>, will not create a query
string.

=cut

sub format_http {
    my($self, $task_id, $query) = @_;
    return 'http://' . $self->get('http_host')
	    . $self->format_uri($task_id, $query);
}

=for html <a name="format_mailto"></a>

=head2 format_mailto(string email, string subject) : string

Creates a mailto URI.  If I<email> is C<undef>, set to
I<auth_realm> owner's name.   If I<email> is missing a host, uses
I<mail_host>.

=cut

sub format_mailto {
    my($self, $email, $subject) = @_;
    my($res) = 'mailto:'
	    . Apache::Util::escape_uri($self->format_email($email));
    $res .= '?subject=' . Apache::Util::escape_uri($subject)
	    if defined($subject);
    return $res;
}

=for html <a name="get_current"></a>

=head2 static get_current() : Bivio::Agent::Request OR undef

Returns the current Request being processed.  To clear the state
of the current request, use L<clear_current|"clear_current">.

=cut

sub get_current {
    return $_CURRENT;
}

=for html <a name="get_fields"></a>

=head2 get_fields(string attr, array_ref names) : hash_ref

Returns the fields of I<attr> specified by I<names>.  Missing
fields are allowed and are returned as C<undef>. If I<attr>
is undefined, returns the empty hash.

=cut

sub get_fields {
    my($self, $attr, $names) = @_;
    $attr = $self->unsafe_get($attr);
    return {} unless ref($attr);
    return {map {
	($_, $attr->{$_});
    } @$names};
}

=for html <a name="get_field"></a>

=head2 get_field(string attr, string name) : hash_ref

Returns the field of I<attr> specified by I<name>.  Missing
fields are allowed and are returned as C<undef>. If I<attr>
is undefined, returns undef.

=cut

sub get_field {
    my($self, $attr, $name) = @_;
    $attr = $self->unsafe_get($attr);
    return ref($attr) ? $attr->{$name} : undef;
}

=for html <a name="get_reply"></a>

=head2 get_reply() : Bivio::Agent::Reply;

DEPRECATED

=cut

sub get_reply {
    return shift->get('reply');
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

Host name configuration. Override this to proxy to another host.

=over 4

=item http_host : string [`hostname` in dotted-decimal]

Host to create absolute URIs.  May contain a port number.

=item mail_host : string ["[$http_host]"]

Host used to create mail_to URIs.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_HTTP_HOST = $cfg->{http_host};
    $_MAIL_HOST = $cfg->{mail_host};
    return;
}

=for html <a name="task_ok"></a>

=head2 task_ok(Bivio::Agent::TaskId task_id) : boolean

This is a shortcut for:

    $self->get('auth_realm')->can_role_execute_task($self->get('auth_role'),
    	    $task_id)

=cut

sub task_ok {
    my($self, $task_id) = @_;
    my($realm, $role) = $self->get('auth_realm', 'auth_role');
    return $realm->can_role_execute_task($role, $task_id, $self);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
