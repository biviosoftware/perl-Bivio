# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Request;
use strict;

$Bivio::Agent::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Request - Abstract request wrapper

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Agent::Request::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Agent::Request> Request provides a common interface for http,
email, ... requests to the application.  The transport specific
Request implementation initializes most of these values

The Attributes are defined:

=over 4

=time auth_id : string

Value of C<auth_realm->get('id')>.

=item auth_realm : Bivio::Auth::Realm

The realm in which the request operates.

=time auth_role : Bivio::Auth::Role

Role I<auth_user> is allowed to play in I<auth_realm>.
Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.

=time auth_user : Bivio::Biz::Model::RealmOwner

The user authenticated with the request.

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

=item query_string : string

URI query string or other agent equivalent.
Is C<undef>, if there is no query_string--still ok to
use C<exists> or C<defined>.

=item reply : Bivio::Agent::Reply

L<Bivio::Agent::Reply|Bivio::Agent::Reply> for this request.

=item request : Bivio::Agent::Request

Always C<$self>.  Convenient for L<get_widget_value|"get_widget_value">.

=item start_time : array_ref

The time the request started as an array of seconds and microseconds.
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
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::General;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::Model::UserRealmList;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::Util;
use Carp ();

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
my($_GENERAL);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::Agent::Request

Creates a request with initial I<attributes>.  I<http_host> and I<mail_host>
will be set as well, but may be overriden by subclass.

=cut

sub new {
    my($proto, $hash) = @_;
    my($self) = &Bivio::Collection::Attributes::new($proto, $hash);
    $self->put(request => $self,
	    http_host => $_HTTP_HOST,
	    mail_host => $_MAIL_HOST);
    return $_CURRENT = $self;
}

=head1 METHODS

=cut

=for html <a name="clear_current"></a>

=head2 static clear_current()

Clears the state of the current request.  See L<get_current|"get_current">.

=cut

sub clear_current {
    # This breaks any circular references, so AGC can work
    defined($_CURRENT) && $_CURRENT->delete_all;
    $_CURRENT = undef;
    return;
}

=for html <a name="die"></a>

=head2 static die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

Terminate the request with a specific code.

=cut

sub die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    $attrs ||= {};
    ref($attrs) eq 'HASH' || ($attrs = {attrs => $attrs});
    $attrs->{request} = $self;
    Bivio::Die->die($code, $attrs, $package, $file, $line);
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

If I<subject> or I<email> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

=cut

sub format_email {
    my($self, $email) = @_;
#TODO: Properly quote the email name???
    $email = $self->get_widget_value(@$email) if ref($email);
    # Will bomb if no auth_realm.
    my($auth_realm) = $self->get('auth_realm');
    Carp::croak($auth_realm->get_type->as_string, ": can't format_email")
		if $auth_realm->get_type eq Bivio::Auth::RealmType::GENERAL();
    $email = $auth_realm->get('owner_name')
	    unless defined($email);
    $email .= '@' . $self->get('mail_host')
	    unless $email =~ /\@/;
    return $email;
}

=for html <a name="format_http"></a>

=head2 format_http(Bivio::Agent::TaskId task_id, hash_ref query, Bivio::Auth::Realm auth_realm) : string

Creates an http URI.  See L<format_uri|"format_uri"> for argument descriptions.

If I<task_id>, I<query> or I<auth_realm> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

=cut

sub format_http {
    my($self) = shift;
    # Must be @_ so format_uri handles overloading properly
    return 'http://' . $self->get('http_host')
	    . $self->format_uri(@_);
}

=for html <a name="format_mailto"></a>

=head2 format_mailto(string email, string subject) : string

Creates a mailto URI.  If I<email> is C<undef>, set to
I<auth_realm> owner's name.   If I<email> is missing a host, uses
I<mail_host>.

If I<subject> or I<email> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

=cut

sub format_mailto {
    my($self, $email, $subject) = @_;
    my($res) = 'mailto:'
	    . Apache::Util::escape_uri($self->format_email($email));
    $subject = $self->get_widget_value(@$subject) if ref($subject);
    $res .= '?subject=' . Apache::Util::escape_uri($subject)
	    if defined($subject);
    return $res;
}

=for html <a name="format_uri"></a>

=head2 abstract format_uri(Bivio::Agent::TaskId task_id) : string

=head2 abstract format_uri(Bivio::Agent::TaskId task_id, string query) : string

=head2 abstract format_uri(Bivio::Agent::TaskId task_id, hash_ref query) : string

=head2 abstract format_uri(Bivio::Agent::TaskId task_id, string query, Bivio::Auth::Realm auth_realm) : string

=head2 abstract format_uri(Bivio::Agent::TaskId task_id, hash_ref query, Bivio::Auth::Realm auth_realm) : string

Creates a URI relative to this host/port.
If I<query> is C<undef>, will not create a query string.
If I<query> is not passed, will use this request's query string.
If I<auth_realm> is not passed, this request's realm will be used.
If I<auth_realm> is C<undef>, the task must not be in an owned realm.

If I<task_id>, I<query> or I<auth_realm> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

=cut

sub format_uri {
    CORE::die('abstract method');
}

=for html <a name="get_auth_role"></a>

=head2 get_auth_role(Bivio::Auth::Realm realm) : Bivio::Auth::Role

Returns auth role for I<realm>.

=cut

sub get_auth_role {
    my($self, $realm) = @_;
    my($realm_id) = $realm->get('id');
    my($auth_id, $auth_user, $auth_role, $user_realms) = $self->unsafe_get(
	    qw(auth_id auth_user auth_role user_realms));

    # Normal case
    return $auth_role if $auth_id eq $realm_id;

    # If no user, then is always anonymous
    return Bivio::Auth::Role::ANONYMOUS() unless $auth_user;

    # Not the current realm, but an authenticated realm
    return $user_realms->{$realm_id}->{'RealmUser.role'}
	    if ref($user_realms->{$realm_id});

    # User has no special privileges in realm other than any other user
    return Bivio::Auth::Role::USER();
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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize()

Called by subclass after it has initialized all state.

=cut

sub internal_initialize {
    my($self, $auth_realm, $auth_user) = @_;
    my($auth_id) = $auth_realm->get('id');
    my($user_realms);
    if ($auth_user) {
	# Load the UserRealmList.  For right now, the auth_id is this
	# user since we don't have a realm.
	my($user_id) = $auth_user->get('realm_id');
	$self->put(auth_id => $user_id);
	my($list) = Bivio::Biz::Model::UserRealmList->new($self);
#TODO: What should this number for "large" lists?
	$list->load({count => 1000});
#TODO: This may be quite expensive if lots of realms(?)
	$user_realms = $list->map_primary_key_to_rows;
    }
    else {
	$user_realms = {};
    }
    # To bootstrap set_realm which calls get_auth_role, we set the
    # auth_id to something that won't match any realm.
    $self->put(
	    auth_realm => $auth_realm,
	    auth_user => $auth_user,
	    user_realms => $user_realms,
	    auth_id => 0,
	   );
    $self->set_realm($auth_realm);
    return;
}

=for html <a name="redirect"></a>

=head2 redirect(Bivio::Agent::TaskId new)

Redirect the current task to the new task.

B<DOES NOT RETURN.>

=cut

sub redirect {
    my($self, $new) = @_;
    # Encapsulates the redirect.  Actually has nothing to do with
    # request, but $req is central mechanism for such things.
    Carp::croak($new, ': not a task id')
		unless UNIVERSAL::isa($new, 'Bivio::Agent::TaskId');
    Bivio::Die->die(Bivio::DieCode::REDIRECT_TASK(),
	    {task_id => $new});
    return;
}

=for html <a name="set_realm"></a>

=head2 set_auth_realm(Bivio::Auth::Realm new_realm)

Changes attributes to be authorized for I<new_realm>.

=cut

sub set_realm {
    my($self, $new_realm) = @_;
    $self->put(auth_realm => $new_realm,
	    auth_id => $new_realm->get('id'),
	    auth_role => $self->get_auth_role($new_realm));
    return;
}

=for html <a name="task_ok"></a>

=head2 task_ok(Bivio::Agent::TaskId task_id) : boolean

=head2 task_ok(Bivio::Agent::TaskId task_id, string realm_id) : boolean

=cut

sub task_ok {
    my($self, $task_id, $realm_id) = @_;
    my($task) = Bivio::Agent::Task->get_by_id($task_id);
    my($trt) = $task->get('realm_type');
    my($realm, $role) = $self->get('auth_realm', 'auth_role');
    my($art) = $realm->get_type;
    # Normal case is for task and realm types to match, if not...
    if (defined($realm_id)) {
#TODO: Need to handle multiple realms, e.g. list of clubs to switch to
	CORE::die("not yet implemented");
    }
    unless ($trt eq $art) {
	# Find the appropriate realm
	if ($trt eq Bivio::Auth::RealmType::GENERAL()) {
	    $_GENERAL = Bivio::Auth::Realm::General->new unless $_GENERAL;
	    $realm = $_GENERAL;
	}
	elsif ($trt eq Bivio::Auth::RealmType::CLUB()) {
#TODO: This is wrong; need to allow user to go to club, from user realm
	    &_trace($task_id, ': for club realm, but no club specified');
	    return 0;
	}
	elsif ($trt eq Bivio::Auth::RealmType::USER()) {
#TODO: Should this look in the user realm list?  This might point
#      to an arbitrary user?
	    my($auth_user) = $self->get('auth_user');
	    if ($auth_user) {
		$realm = $self->unsafe_get('auth_user_realm');
		unless ($realm) {
		    $realm = Bivio::Auth::Realm::User->new($auth_user);
		    $self->put(auth_user_realm => $realm);
		}
	    }
	    else {
		&_trace($task_id, ': for user realm, but no auth_user');
		return 0;
	    }
	}
	else {
	    CORE::die($trt->as_string, ': unknown realm type for ',
		    $task_id->as_string);
	}
    }
    return $realm->can_user_execute_task($task, $self);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
