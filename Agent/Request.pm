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

=item auth_role : Bivio::Auth::Role

Role I<auth_user> is allowed to play in I<auth_realm>.
Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.

=item auth_user : Bivio::Biz::Model::RealmOwner

The user authenticated with the request.

=item cookie : hash_ref

This is the cookie that came in the HTTP header.  It may be
C<undef>.  Very few tasks should access the cookie directly.
If at all possible, the hidden form fields and the query string should
be used to maintain state.

Any fields set in the request cookie will be set in the reply.
See L<Bivio::Agent::HTTP::Cookie|Bivio::Agent::HTTP::Cookie>
for details.

=item cookie_state : Bivio::Agent::HTTP::CookieState

Indicates the state of the cookie that arrived with the request.
It may be C<undef>.

=item form : hash_ref

Attributes in url-encoded POST body or other agent equivalent.
Is C<undef>, if method was not POST or equivalent.
NOTE: Forms must always have unique value names--still ok to
use C<exists> or C<defined>.

=item mailhost : string

Host name to be used in mailto URLs and such.

=item message : Bivio::Mail::Incoming

Mail message represented by this request.

=item prev_form : hash_ref

Will be set if there is a server redirect and the initial request
had a form.  Will be overwritten with multiple redirects within same request.

=item prev_query : hash_ref

Will be set if there is a server redirect.  Contains the original
hash_ref.  Will be overwritten with multiple redirects within same request.

=item prev_uri : string

Will be set if there is a server redirect.  Contains the original
URI.  Will be overwritten with multiple redirects within same request.

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

=item unauth_user : Bivio::Biz::Model::RealmOwner

The user in a the request which could had insufficient authentication
information.  This typically is set if the cookie expires, but is
otherwise correct.  Currently only used in C<LoginForm>.

=item E<lt>ModuleE<gt> : Bivio::UNIVERSAL

Maps I<E<lt>ModuleE<gt>> to an instance of that modules.  Actions
and Views will put instances as they are initialized on to the request.
If there is an owner to the I<auth_realm>, this will be the first
L<Bivio::Biz::Model|Bivio::Biz::Model> added to the request.

=back

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Query;
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::General;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::Action::CreateDemoClub;
use Bivio::Biz::Model::UserRealmList;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::RealmName;
use Bivio::Util;
use Carp ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_HTTP_HOST) = sprintf('%d.%d.%d.%d',
	unpack('C4', (gethostbyname(substr(`hostname`, 0, -1)))[4]));
my($_MAIL_HOST) = "[$_HTTP_HOST]";
my($_SUPPORT_PHONE);
my($_SUPPORT_EMAIL);
Bivio::IO::Config->register({
    mail_host =>  $_MAIL_HOST,
    http_host =>  $_HTTP_HOST,
    support_phone => Bivio::IO::Config->REQUIRED,
    support_email => Bivio::IO::Config->REQUIRED,
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
	    mail_host => $_MAIL_HOST,
	    support_phone => $_SUPPORT_PHONE,
	    support_email => $_SUPPORT_EMAIL,
	   );
    return $_CURRENT = $self;
}

=head1 METHODS

=cut

=for html <a name="can_user_execute_task"></a>

=head2 can_user_execute_task(Bivio::Agent::TaskId task) : boolean

Convenience routine which executes
L<Bivio::Auth::Realm::can_user_execute_task|Bivio::Auth::Realm/"can_user_execute_task">
for the current I<auth_realm> and current I<auth_user>.

=cut

sub can_user_execute_task {
    my($self, $task) = @_;
    return $self->get('auth_realm')->can_user_execute_task(
	    Bivio::Agent::Task->get_by_id($task), $self);
}

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

=for html <a name="client_redirect"></a>

=head2 client_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query)

Redirects the client to the location of the specified new_task. By default,
this uses L<redirect|"redirect">, but subclasses (HTTP) should override this
to force a hard redirect.

B<DOES NOT RETURN>.

=cut

sub client_redirect {
    my($self) = shift;
    return $self->server_redirect(@_);
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
#TODO: Check $ENV{HTTPS} to see if set and generate URL based on that?
#      Need to know if uri itself is in SSL domain...  Add another
#      attribute to task?  Check to see if anonymous can access?
#      See if task has a realm owner?
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
    my($auth_id, $auth_role) = $self->unsafe_get(qw(auth_id auth_role));

    # Use (cached) value in $self if realm_id is the same.  Otherwise,
    # go through entire lookup process.
    return $auth_id eq $realm_id ? $auth_role : _get_role($self, $realm_id);
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

=for html <a name="get_http_host"></a>

=head2 get_http_host() : string

Returns the http host name used for configuration.

=cut

sub get_http_host {
    return $_HTTP_HOST;
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

=item support_phone : string (required)

Phone number to be displayed to get support.

=item support_email : string (required)

email to be displayed to get support

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_HTTP_HOST = $cfg->{http_host};
    $_MAIL_HOST = $cfg->{mail_host};
    $_SUPPORT_PHONE = $cfg->{support_phone};
    $_SUPPORT_EMAIL = $cfg->{support_email};
    return;
}

=for html <a name="internal_get_realm_for_task"></a>

=head2 internal_get_realm_for_task(Bivio::Agent::TaskId task_id) : Bivio::Auth::Realm

Returns the realm for the specified task.  If the realm type of the
task matches the current realm, current realm is returned.  Otherwise,
we return the best realm that matches the type of the task.

=cut

sub internal_get_realm_for_task {
    my($self, $task_id) = @_;
    # If is current task, just return current realm.
    my($realm) = $self->get('auth_realm');
    return $realm if $task_id == $self->get('task_id');
    my($task) = Bivio::Agent::Task->get_by_id($task_id);
    my($trt) = $task->get('realm_type');
    return $realm if $trt == $realm->get_type;
    # Else, different realm type, look up
    return _get_realm($self, $trt, $task_id);
}

=for html <a name="internal_redirect_realm"></a>

=head2 internal_redirect_realm(TaskId new_task, Realm new_realm) : Realm

Changes the current realm if required by the new task.

=cut

sub internal_redirect_realm {
    my($self, $new_task, $new_realm) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($task) = Bivio::Agent::Task->get_by_id($new_task);

    my($trt) = $task->get('realm_type');
    if ($new_realm) {
	# Assert param
	my($nrt) = $new_realm->get_type;
	Carp::croak($new_task->as_string, 'realm_type mismatch (',
		$trt->get_name, ' != ', $nrt, ')') unless $trt eq $nrt;
    }
    else {
	# Only set realm if type is different
	my($ar) = $self->get('auth_realm');
	unless ($ar->get_type eq $trt) {
	    $new_realm = _get_realm($self, $trt, $new_task);
	    # No new realm, do something reasonable
	    unless (defined($new_realm)) {
		if ($trt eq Bivio::Auth::RealmType::CLUB()) {
		    # Club not found.  Try to redirect to MY_CLUB_NOT_FOUND
		    # which must be in GENERAL domain
		    my($auth_user) = $self->unsafe_get('auth_user');
		    if (defined($auth_user)) {
			CORE::die('misconfiguration of MY_CLUB_NOT_FOUND task')
				if Bivio::Agent::TaskId::MY_CLUB_NOT_FOUND()
					eq $new_task;
			$self->client_redirect(
				Bivio::Agent::TaskId::MY_CLUB_NOT_FOUND());
		    }
		}
		Bivio::Die->die('AUTH_REQUIRED', {
		    auth_user => undef,
		    entity => Bivio::Auth::RealmType::USER(),
		    auth_role => undef,
		    operation => $new_task});
	    }
	}
    }
    # Change realms before formatting uri
    $self->set_realm($new_realm) if $new_realm;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize()

Called by subclass after it has initialized all state.

=cut

sub internal_initialize {
    my($self, $auth_realm, $auth_user) = @_;
    # By default, set_user also sets auth_role.  The 1 turns this off.
    $self->set_user($auth_user, 1);
    $self->set_realm($auth_realm);
    return;
}

=for html <a name="internal_server_redirect"></a>

=head2 internal_server_redirect(Bivio::Agent::Request self, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form)

Sets all values and saves I<prev_query>, etc.

=cut

sub internal_server_redirect {
    my($self, $new_task, $new_realm, $new_query, $new_form) = @_;
    # Keep the request's query for context on form OK and CANCEL.
    my($form, $uri, $query) = $self->unsafe_get(qw(form uri query));
    $self->internal_redirect_realm($new_task, $new_realm);
    $self->put(uri => $self->format_uri($new_task, undef),
	    query => $new_query,
	    query_string => Bivio::Agent::HTTP::Query->format($new_query),
	    form => $new_form,
	    prev_form => $form,
	    prev_uri => $uri,
	    prev_query => $query);
    return;
}

=for html <a name="server_redirect"></a>

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form)

Server_redirect the current task to the new task.

B<DOES NOT RETURN.>

=cut

sub server_redirect {
    my($self, $new_task, $new_realm, $new_query, $new_form) = @_;
    $self->internal_server_redirect($new_task, $new_realm,
		$new_query, $new_form);
    Bivio::Die->die(Bivio::DieCode::SERVER_REDIRECT_TASK(),
	    {task_id => $new_task});
    return;
}

=for html <a name="server_redirect_in_handle_die"></a>

=head2 server_redirect_in_handle_die(Bivio::Die die, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form)

Same as L<server_redirect|"server_redirect">, but puts the attributes
on I<die> instead of executing L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub server_redirect_in_handle_die {
    my($self, $die, $new_task, $new_realm, $new_query, $new_form) = @_;
    $self->internal_server_redirect($new_task, $new_realm,
	    $new_query, $new_form);
    $die->get('attrs')->{task_id} = $new_task;
    $die->put(code => Bivio::DieCode::SERVER_REDIRECT_TASK());
    return;
}

=for html <a name="set_realm"></a>

=head2 set_realm(Bivio::Auth::Realm new_realm)

Changes attributes to be authorized for I<new_realm>.  Also
sets C<auth_role>.

=cut

sub set_realm {
    my($self, $new_realm) = @_;
    my($realm_id) = $new_realm->get('id');
    $self->put(auth_realm => $new_realm,
	    auth_id => $realm_id,
	    auth_role => _get_role($self, $realm_id));
    return;
}

=for html <a name="set_user"></a>

=head2 set_user(Bivio::Biz::Model::RealmOwner user)

Sets I<user> to be C<auth_user>.  May be C<undef>.  Also caches
user_realms.

=cut

sub set_user {
    # dont_set_role is used internally, don't pass if outside this module.
    my($self, $user, $dont_set_role) = @_;
    my($user_realms);
    if ($user) {
	# Load the UserRealmList.  For right now, the auth_id is this
	# user since we don't have a realm.
	my($user_id) = $user->get('realm_id');
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
    $self->put(auth_user => $user, user_realms => $user_realms);
    # Set the (cached) auth_role if requested (by default).
    $self->put(auth_role => _get_role($self, $self->get('auth_id')))
	    unless $dont_set_role;
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
	$realm = _get_realm($self, $trt, $task_id);
	return 0 unless $realm;
    }
    return $realm->can_user_execute_task($task, $self);
}

#=PRIVATE METHODS

# _get_realm(Bivio::Agent::Request self, Bivio::Auth::RealmType realm_type, Bivio::Agent::TaskId task_id) : Bivio::Auth::Realm
#
# Returns the realm for the specified type.  task_id is passed for
# debugging purposes.
#
sub _get_realm {
#TODO: This method should be in application code.  Probably should have
#      hook for managing realms.  This is the only mention of clubs in
#      all of this code.
    my($self, $realm_type, $task_id) = @_;
    # Find the appropriate realm
    if ($realm_type eq Bivio::Auth::RealmType::GENERAL()) {
	$_GENERAL = Bivio::Auth::Realm::General->new unless $_GENERAL;
	return $_GENERAL;
    }
    if ($realm_type eq Bivio::Auth::RealmType::CLUB()) {
#TODO: Why don't we want to return the demo_club?
	my($demo_suffix) = Bivio::Type::RealmName::DEMO_CLUB_SUFFIX();
	my($user_realms) = $self->get('user_realms');
	my($role, $realm_id) = Bivio::Auth::Role::UNKNOWN->as_int;
	foreach my $r (values(%$user_realms)) {
	    next unless $r->{'RealmOwner.realm_type'}
		    eq Bivio::Auth::RealmType::CLUB();
	    my($rr) = $r->{'RealmUser.role'}->as_int;
	    next unless  $rr > $role;
	    next if $r->{'RealmOwner.name'} =~ /$demo_suffix$/x;
	    $realm_id = $r->{'RealmUser.realm_id'};
	    $role = $rr;
	}
	return undef unless $realm_id;
	my($club) = Bivio::Biz::Model::RealmOwner->new($self);
#TODO: This will bomb if the realm disappeared since (cached) user_realms
#      was accessed.
	$club->unauth_load(realm_id => $realm_id);
	return Bivio::Auth::Realm::Club->new($club);
    }
    if ($realm_type eq Bivio::Auth::RealmType::USER()) {
#TODO: Should this look in the user realm list?  This might point
#      to an arbitrary user?
	my($auth_user) = $self->get('auth_user');
	if ($auth_user) {
	    my($realm) = $self->unsafe_get('auth_user_realm');
	    unless ($realm) {
		$realm = Bivio::Auth::Realm::User->new($auth_user);
		$self->put(auth_user_realm => $realm);
	    }
	    return $realm;
	}
	&_trace($task_id, ': for user realm, but no auth_user');
#TODO: Distinguish between auth_user case and other cases
	return undef;
    }
    CORE::die($realm_type->as_string, ': unknown realm type for ',
	    $task_id->as_string);
}

# _get_role(Bivio::Agent::Request self, string realm_id) : Bivio::Auth::Role
#
# Does the work for get_auth_role().
#
sub _get_role {
    my($self, $realm_id) = @_;
    my($auth_user, $user_realms) = $self->unsafe_get(
	    qw(auth_user user_realms));

    # If no user, then is always anonymous
    return Bivio::Auth::Role::ANONYMOUS() unless $auth_user;

    # Not the current realm, but an authenticated realm
    return $user_realms->{$realm_id}->{'RealmUser.role'}
	    if ref($user_realms->{$realm_id});

    # User has no special privileges in realm 
    return Bivio::Auth::Role::USER();
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
