# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Request;
use strict;

$Bivio::Agent::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::Request::VERSION;

=head1 NAME

Bivio::Agent::Request - Abstract request wrapper

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Agent::Request::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Agent::Request> Request provides a common interface for http,...
requests to the application.  The transport specific
Request implementation initializes most of these values

=head1 ATTRIBUTES

During request processing, attributes are added to the Request object.
Some attributes are models (by class name, see below).  Others are
"standard", i.e. those shown below.  Yet others are task specific.

Attributes specific to a task should be uniquely named so thery
can be found easily in the code and to avoid name space collisions.
They should be documented in the class which sets them under
the B<REQUEST ATTRIBUTES> heading.  See, for example,
L<Bivio::Biz::Model::FilePathList|Bivio::Biz::Model::FilePathList>.

Task specific attributes should be avoided in general.  Try to
put the state in a model, e.g. a FormModel or ListModel with local
fields.

=over 4

=item auth_id : string

Value of C<auth_realm->get('id')>.

=item auth_realm : Bivio::Auth::Realm

The realm in which the request operates.

=item auth_role : Bivio::Auth::Role

Role I<auth_user> is allowed to play in I<auth_realm>.
Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.

=item auth_user : Bivio::Biz::Model::RealmOwner

The user authenticated with the request.

=item auth_user_id : string

The user id authenticated with the request.  Set before I<auth_user>
as a part of cookie processing.

=item Bivio::Type::UserAgent : Bivio::Type::UserAgent

The type of the user agent for this request.

=item can_secure : boolean

Can this server function in secure mode?

=item client_addr : string

Client's network address if available.

=item cookie : Bivio::Agent::Cookie

This is the cookie that came in the HTTP header.  It may be
C<undef> only if the protocol doesn't support cookies.
Very few tasks should access the cookie directly.
If at all possible, the hidden form fields and the query string should
be used to maintain state.

Any fields set in the request cookie will be set in the reply,
i.e. there is only one cookie for request/reply.
See L<Bivio::Agent::HTTP::Cookie|Bivio::Agent::HTTP::Cookie>
for details.

=item form : hash_ref

Attributes in url-encoded POST body or other agent equivalent.
Is C<undef>, if method was not POST or equivalent.
NOTE: Forms must always have unique value names--still ok to
use C<exists> or C<defined>.

This value is initialized by FormModel, not by Request.

=item initial_uri : string

URI which came in with the request (sans facade, but including
path_info).

=item is_production : boolean

Are we running in production mode?

=item is_secure : boolean

Are we running in secure mode (SSL)?

=item message : Bivio::Mail::Message

Mail message represented by this request.

=item path_info : string

The dynamic part of the URI.   The name comes from CGI which defines
a C<PATH_INFO> variable in scripts.  In our world, the dynamic part
can be anywhere.  Treat C<undef> and the empty string identically.

B<Always begins with C</> if defined.>  Unlike CGI, I<path_info> is
not extracted from I<uri>.  I<path_info> is used to generate other
URIs, not to recreate the existing one.

B<It is not escaped.>  UI::Task and Biz::ListModel
will escape it before appending.

=item query : hash_ref

Attributes in URI query string or other agent equivalent.
Is C<undef>, if there are no query args--still ok to
use C<exists> or C<defined>.

NOTE: Query strings must always have unique value names.

=item reply : Bivio::Agent::Reply

L<Bivio::Agent::Reply|Bivio::Agent::Reply> for this request.

=item request : Bivio::Agent::Request

Always C<$self>.  Convenient for L<get_widget_value|"get_widget_value">.

=item super_user_id : string

If the request is operating is substitute user mode, this is the
id of the super user.

=item start_time : array_ref

The time the request started as an array of seconds and microseconds.
See L<Bivio::Type::DateTime->gettimeofday|Bivio::Util/"gettimeofday">.

=item target_realm_owner : Bivio::Biz::Model::RealmOwner

Set by L<Bivio::Biz::Action::TargetRealm|Bivio::Biz::Action::TargetRealm>.
Used to allow a different realm to be operated on within the current
realm.  Allows shareable code for AddressForm and such.

You can use I<target_realm_owner> as an "authenticated" value, because
C<TargetRealm> checks permissions properly.  Don't use "this" as
an authenticated value.  See
L<Bivio::UI::HTML::Club::UserDetail|Bivio::UI::HTML::Club::UserDetail>
for an example when it loads C<TaxId>.

=item task : Bivio::Agent::Task

Tuple containing the Action and View to be executed.
Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.

=item task_id : Bivio::Agent::TaskId

Same as I<task>'s I<id>.

=item timezone : int

The user's timezone (if available).  The timezone is an offsite in
minutes from GMT.  See use in
L<Bivio::Type::DateTime|Bivio::Type::DateTime>.

=item txn_resources : array_ref

The list of resources (objects) which have transaction handlers
(handle_commit and handle_rollback).  The handlers are called before
any commit or rollback.  Examples:
L<Bivio::Biz::Model::Lock|Bivio::Biz::Model::Lock>
and L<Bivio::Societas::Biz::Model::Preferences|Bivio::Societas::Biz::Model::Preferences>.

Handlers are called and cleared by L<Bivio::Agent::Task|Bivio::Agent::Task>.

=item user_state : Bivio::Type::UserState

Is the user just a visitor, logged in, or out?  Set by LoginForm.

=item uri : string

URI from the incoming request unmodified.  It is already "escaped".

=item E<lt>ModuleE<gt> : Bivio::UNIVERSAL

Maps I<E<lt>ModuleE<gt>> to an instance of that modules.  Facade, Actions
and Views will put instances as they are initialized on to the request.
If there is an owner to the I<auth_realm>, this will be the first
L<Bivio::Biz::Model|Bivio::Biz::Model> added to the request.

=back

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Query;
use Bivio::Agent::Task;
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::General;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::FormModel;
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::UserAgent;
# We don't import any UI components here, because they are
# initialized by Bivio::Agent::Dispatcher

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_IS_PRODUCTION) = 0;
my($_CAN_SECURE);
Bivio::IO::Config->register({
    is_production => $_IS_PRODUCTION,
    can_secure => 1,
});
my($_CURRENT);
my($_GENERAL);

=head1 FACTORIES

=cut

=for html <a name="internal_new"></a>

=head2 static internal_new(hash_ref attributes) : Bivio::Agent::Request

B<Don't call unless you are a subclass.>
Use L<get_current_or_new|"get_current_or_new">.

Creates a request with initial I<attributes>.

Subclasses must call L<internal_set_current|"internal_set_current">
when the instance is sufficiently initialized.

=cut

sub internal_new {
    my($proto, $hash) = @_;
    my($self) = &Bivio::Collection::Attributes::new($proto, $hash);
    $self->put_durable(durable_keys => {durable_keys => 1});
    $self->put_durable(request => $self,
	    is_production => $_IS_PRODUCTION,
	    txn_resources => [],
	    can_secure => $_CAN_SECURE,
	   );
    # Make sure a value gets set
    Bivio::Type::UserAgent->execute_unknown($self);
    return $self;
}

=for html <a name="new"></a>

=head2 static new()

B<Terminates caller.>  Use L<get_current_or_new|"get_current_or_new">.

=cut

sub new {
    die('only can initialize from subclasses');
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the important request context as a string.  Items currently
returned: task, user, referer, uri, query, and form.

=cut

sub as_string {
    my($self) = @_;
    my($r) = $self->unsafe_get('r');
    my($t) = $self->unsafe_get('task_id');
    return 'Request['.Bivio::IO::Alert->format_args(
	    'task=', $t ? $t->get_name : undef,
	    ' user=', $r ? $r->connection->user : undef,
	    ' referer=', $r ? $r->header_in('Referer') : undef,
	    ' uri=', $self->unsafe_get('uri'),
	    ' query=', $self->unsafe_get('query'),
	    ' form=', _form_for_warning($self),
	   ).']';
}

=for html <a name="can_user_execute_task"></a>

=head2 can_user_execute_task(Bivio::Agent::TaskId task) : boolean

=head2 can_user_execute_task(string task_name) : boolean

Convenience routine which executes
L<Bivio::Auth::Realm::can_user_execute_task|Bivio::Auth::Realm/"can_user_execute_task">
for the I<auth_realm> or one that matches the realm_type of the task
and current I<auth_user>.

=cut

sub can_user_execute_task {
    my($self, $task) = @_;
    $task = Bivio::Agent::TaskId->from_name($task) unless ref($task);

    # If we can't get a realm, than can execute task
    my($realm) = $self->get_realm_for_task($task);
    return 0 unless $realm;

    # Execute in this realm?
    return $realm->can_user_execute_task(
	    Bivio::Agent::Task->get_by_id($task), $self);
}

=for html <a name="clear_current"></a>

=head2 static clear_current()

Clears the state of the current request.  See L<get_current|"get_current">.

=cut

sub clear_current {
    # This breaks any circular references, so AGC can work
    $_CURRENT->delete_all if $_CURRENT;
    $_CURRENT = undef;
    return;
}

=for html <a name="clear_nondurable_state"></a>

=head2 clear_nondurable_state()

Clears out models (Bivio::Biz::*) and any other nondurable state.  This
method will be expanded over time.

=cut

sub clear_nondurable_state {
    my($self) = @_;
#    # This is a hack for now
#    $self->delete(grep(/Bivio::Biz::/, @{$self->get_keys}));
#    $self->delete(grep(/Bivio::Societas::Biz::/, @{$self->get_keys}));
#    $self->delete(grep(/^Model\./, @{$self->get_keys}));
#    return;

    my($durable_keys) = $self->get('durable_keys');
    my(@non_durable_keys) = map { $durable_keys->{$_} ? () : $_ }
	    @{$self->get_keys};
    _trace("durable keys: ".join(',', keys(%$durable_keys))) if $_TRACE;
    _trace("NON durable keys: ".join(',', @non_durable_keys)) if $_TRACE;
    $self->delete(@non_durable_keys);
    return;
}

=for html <a name="client_redirect"></a>

=head2 client_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, string new_path_info, boolean no_context)

Redirects the client to the location of the specified new_task. By default,
this uses L<redirect|"redirect">, but subclasses (HTTP) should override this
to force a hard redirect.

B<DOES NOT RETURN>.

=cut

sub client_redirect {
    my($self) = shift;
    return $self->server_redirect(@_);
}

=for html <a name="client_redirect_contextless"></a>

=head2 client_redirect_contextless(Bivio::Agent::TaskId task, any realm, any query, string path_info)

=head2 client_redirect_contextless(string uri, any realm, any query, string path_info)

Calls L<client_redirect|"client_redirect"> without state or context.
If I<realm> is undef, chooses appropriate realm.
If I<query> is undef, there is no query.
If I<path_info> is undef, there is no path_info.

=cut

sub client_redirect_contextless {
    my($self, $uri_task, $realm, $query, $path_info) = @_;
    $self->client_redirect($uri_task, $realm, $query, $path_info, 1);
    # DOES NOT RETURN
}

=for html <a name="elapsed_time"></a>

=head2 elapsed_time() : float

Returns the number of seconds elapsed since the request was created.

=cut

sub elapsed_time {
    my($self) = @_;
    return Bivio::Type::DateTime->gettimeofday_diff_seconds(
	    $self->get('start_time'));
}

=for html <a name="format_email"></a>

=head2 format_email(string email) : string

Formats the email address for inclusion in a mail header.
If the host is missing, adds I<Text.mail_host>.

If I<subject> or I<email> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

=cut

sub format_email {
    my($self, $email) = @_;
#TODO: Properly quote the email name???
    $email = $self->get_widget_value(@$email) if ref($email);
    # Will bomb if no auth_realm.
    return $self->get('auth_realm')->format_email unless defined($email);
    $email .= '@' .Bivio::UI::Text->get_value('mail_host', $self)
	    unless $email =~ /\@/;
    return $email;
}

=for html <a name="format_help_uri"></a>

=head2 format_help_uri(any task_id) : string

Formats the uri for I<task_id> (defaults to task_id on request).  If the task
doesn't have a help entry, defaults to default help page.

I<task_id> may be a widget value, string (the name), or
a L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

=cut

sub format_help_uri {
    my($self, $task_id) = @_;
    $task_id = $self->get_widget_value(@$task_id) if ref($task_id) eq 'ARRAY';
    $task_id = $task_id ? ref($task_id) ? $task_id
	    : Bivio::Agent::TaskId->from_any($task_id)
		    : $self->get('task_id');
    return Bivio::UI::Task->format_help_uri($task_id, $self);
}

=for html <a name="format_http"></a>

=head2 format_http(any task_id, hash_ref query, any auth_realm, boolean no_context) : string

=head2 format_http(any task_id, string query, any auth_realm, boolean no_context) : string

Creates an http URI.  See L<format_uri|"format_uri"> for argument descriptions.

If I<task_id>, I<query> or I<auth_realm> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

Handles I<require_secure> according to rules in L<format_uri|"format_uri">.

=cut

sub format_http {
    my($self) = shift;
    # Must be @_ so format_uri handles overloading properly
    my($uri) = $self->format_uri(@_);
    return $uri =~ /^\w+:/ ? $uri : $self->format_http_prefix.$uri;
}

=for html <a name="format_http_insecure"></a>

=head2 format_http_insecure(Bivio::Agent::TaskId task_id, hash_ref query, any auth_realm, boolean no_context) : string

=head2 format_http_insecure(Bivio::Agent::TaskId task_id, string query, any auth_realm, boolean no_context) : string


=cut

sub format_http_insecure {
    my($self) = shift;
    # Must be @_ so format_uri handles overloading properly
    my($uri) = $self->format_uri(@_);
    return $uri if $uri =~ s/^https:/http:/;
    return 'http://'.Bivio::UI::Text->get_value('http_host', $self).$uri;
}

=for html <a name="format_http_prefix"></a>

=head2 format_http_prefix(boolean require_secure) : string

Returns the http or https prefix for this I<Text.http_host>.  Does not add
trailing '/'.

You should pass in the I<require_secure> value for the task you are
rendering for.

=cut

sub format_http_prefix {
    my($self, $require_secure) = @_;
    # If is_secure is not set, default to non-secure
    return ($self->unsafe_get('is_secure') || $require_secure
	    ? 'https://' : 'http://')
	    .Bivio::UI::Text->get_value('http_host', $self);
}

=for html <a name="format_mailto"></a>

=head2 format_mailto(string email, string subject) : string

Creates a mailto URI.  If I<email> is C<undef>, set to
I<auth_realm> owner's name.   If I<email> is missing a host, uses
I<Text.mail_host>.

If I<subject> or I<email> is an array_ref, will call
L<get_widget_value|"get_widget_value"> with array value to get value.

=cut

sub format_mailto {
    my($self, $email, $subject) = @_;
    my($res) = 'mailto:'
	    . Bivio::HTML->escape_uri($self->format_email($email));
    $subject = $self->get_widget_value(@$subject) if ref($subject);
    if (defined($subject)) {
	# This is a bug.  Currently Outlook doesn't understand
	# escaped URIs in mailtos.  We should be escap_uri'ing the subject.
	# Make sure there are no quotes, percents, or backslashes, though.
	# Percent must be first
	$subject =~ s/\%/%22/g;
	$subject =~ s/\"/%25/g;
	$subject =~ s/\\/%5C/g;
	$res .= '?subject=' . $subject;
    }
    return $res;
}

=for html <a name="format_stateless_uri"></a>

=head2 format_stateless_uri(any task_id) : string

Creates a URI relative to this host/port/realm without a query string.

=cut

sub format_stateless_uri {
    my($self, $task_id) = @_;
    return $self->format_uri($task_id, undef, undef, undef);
}

=for html <a name="format_uri"></a>

=head2 format_uri(any task_id, string query, any realm, string_path_info, boolean no_context) : string

=head2 format_uri(any task_id, hash_ref query, any realm, string path_info, boolean no_context) : string

Creates a URI relative to this host:port.
If I<query> is C<undef>, will not create a query string.
If I<query> is not passed, will use this request's query string.
If the task doesn't I<want_query>, will not append query string.
If the task does I<require_secure>, will prefix https: unless
the page is already secure.
If I<auth_realm> is C<undef>, request's realm will be used.
If I<path_info> is C<undef>, request's path_info will be used.

If any of the values is an array_ref, it will be evaluated as a widget_value.

If the task doesn't have a uri, returns C<undef>.

I<no_context> allows the caller to not allow FormContext.

=cut

sub format_uri {
    my($self, $task_id, $query, $auth_realm, $path_info, $no_context) = @_;
    $task_id = $self->get_widget_value(@$task_id) if ref($task_id) eq 'ARRAY';
    $query = $self->get_widget_value(@$query) if ref($query) eq 'ARRAY';
    $auth_realm = $self->get_widget_value(@$auth_realm)
	    if ref($auth_realm) eq 'ARRAY';
    $path_info = $self->get_widget_value(@$path_info)
	    if ref($path_info) eq 'ARRAY';
    if ($task_id) {
	$task_id = Bivio::Agent::TaskId->from_name($task_id)
		unless ref($task_id) eq 'Bivio::Agent::TaskId';
    }
    else {
	# Default
	$task_id = $self->get('task_id');
    }

    # Allow path_info to be undef
    $path_info = $self->unsafe_get('path_info') unless int(@_) >= 5;

    my($uri) = Bivio::UI::Task->format_uri(
	    $task_id,
	    defined($auth_realm) ? $auth_realm
	    : $self->get_realm_for_task($task_id),
	    $path_info,
	    $no_context,
	    $self,
	   );

    # Yes, we don't want $query unless it is passed.
    $query = $self->get('query') unless int(@_) >= 3;
    my($task) = Bivio::Agent::Task->get_by_id($task_id);
    $uri = $self->format_http_prefix(1).$uri
	    if $task->get('require_secure') && !$self->unsafe_get('is_secure')
		    && $self->get('can_secure');

    return $uri unless defined($query) && $task->get('want_query');
    $query = Bivio::Agent::HTTP::Query->format($query) if ref($query);

    # The uri may have a query string already, if the form requires context.
    # Put the $query first, since the context is long and ugly
    $uri =~ s/\?/?$query&/ || ($uri .= '?'.$query)
	    if length($query);
    return $uri;
}

=for html <a name="get_auth_role"></a>

=head2 get_auth_role(string realm_id) : Bivio::Auth::Role

=head2 get_auth_role(Bivio::Auth::Realm realm) : Bivio::Auth::Role

Returns auth role for I<realm>.

=cut

sub get_auth_role {
    my($self, $realm) = @_;
    my($realm_id) = ref($realm) ? $realm->get('id') : $realm;
    my($auth_id, $auth_role) = $self->unsafe_get(qw(auth_id auth_role));

    # Use (cached) value in $self if realm_id is the same.  Otherwise,
    # go through entire lookup process.
    return $auth_id eq $realm_id ? $auth_role : _get_role($self, $realm_id);
}

=for html <a name="get_current"></a>

=head2 static get_current() : Bivio::Agent::Request

Returns the current Request being processed.  To clear the state
of the current request, use L<clear_current|"clear_current">.

=cut

sub get_current {
    return $_CURRENT;
}

=for html <a name="get_current_or_new"></a>

=head2 static get_current_or_new() : Bivio::Agent::Request

Returns the current request or creates as new one.  To be used
for utilities.

=cut

sub get_current_or_new {
    my($proto) = @_;
    my($current) = $proto->get_current;
    return $current if $current;

    # This class doesn't set current; need to do it explicitly
    return $proto->internal_new()->internal_set_current
	    if $proto eq __PACKAGE__;

    # Subclasses set current
    return $proto->new();
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

=for html <a name="get_form"></a>

=head2 get_form() : hash_ref

Returns undef.

=cut

sub get_form {
    return undef;
}

=for html <a name="get_realm_for_task"></a>

=head2 get_realm_for_task(Bivio::Agent::TaskId task_id) : Bivio::Auth::Realm

Returns the realm for the specified task.  If the realm type of the
task matches the current realm, current realm is returned.  Otherwise,
we return the best realm that matches the type of the task.

=cut

sub get_realm_for_task {
    my($self, $task_id) = @_;
    # If is current task, just return current realm.
    my($realm) = $self->get('auth_realm');
    return $realm if $task_id == $self->get('task_id');
    my($task) = Bivio::Agent::Task->get_by_id($task_id);
    my($trt) = $task->get('realm_type');
    return $realm if $trt == $realm->get('type');
    # Else, different realm type, look up
    return _get_realm($self, $trt, $task_id);
}

=for html <a name="get_request"></a>

=head2 static get_request() : Bivio::Agent::Request

Returns I<self> if not called statically, else returns
I<get_current_or_new>.

Called I<get_request> so callers don't have to worry about getting
request from non-Biz::Model sources.  Calling I<get_request> always
works on I<$source>.

=cut

sub get_request {
    my($proto) = @_;
    return ref($proto) ? $proto : $proto->get_current_or_new;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

Host name configuration. Override this to proxy to another host.

=over 4

=item can_secure : boolean [1]

Only used for development systems (single server mode), which can't
run in secure mode.

=item is_production : boolean [false]

Are we running in production mode?

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_IS_PRODUCTION = $cfg->{is_production};
    $_CAN_SECURE = $cfg->{can_secure};
    return;
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
	my($nrt) = $new_realm->get('type');
	Bivio::Die->die($new_task->as_string, 'realm_type mismatch (',
		$trt->get_name, ' != ', $nrt, ')') unless $trt eq $nrt;
    }
    else {
	# Only set realm if type is different
	my($ar) = $self->get('auth_realm');
	unless ($ar->get('type') eq $trt) {
	    $new_realm = _get_realm($self, $trt, $new_task);
	    # No new realm, do something reasonable
	    unless (defined($new_realm)) {
		if ($trt eq Bivio::Auth::RealmType::CLUB()) {
		    # GO TO HOME instead of a club.  He can choose
		    # realm chooser
		    $self->client_redirect(Bivio::Agent::TaskId::USER_HOME())
		}

		# Need to login as a user.
		$self->server_redirect(Bivio::Agent::TaskId::LOGIN());
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

=head2 internal_server_redirect(Bivio::Agent::Request self, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form, string new_path_info, boolean no_context)

=head2 internal_server_redirect(Bivio::Agent::Request self, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, hash_ref new_form, string new_path_info, boolean no_context)

=head2 internal_server_redirect(Bivio::Agent::Request self, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, string new_path_info, boolean no_context)

=head2 internal_server_redirect(Bivio::Agent::Request self, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, string new_path_info, boolean no_context)

Sets all values and saves form context.

The second form is used by L<client_redirect|"client_redirect">.

=cut

sub internal_server_redirect {
    my($self, $new_task, $new_realm, $new_query, $new_form, $new_path_info,
	    $no_context) = @_;
    Bivio::UI::Task->assert_defined_for_facade($new_task, $self);

    # Save the form context before switching realms
    my($fc) = Bivio::Biz::FormModel->get_context_from_request($self);

    # Set the realm AND task, because they MUST match.
    # This matches what the Dispatcher will do.
    #NOTE: Coupling with Dispatcher::process_request.
    $self->internal_redirect_realm($new_task, $new_realm);
    $self->put(task_id => $new_task,
	    task => Bivio::Agent::Task->get_by_id($new_task));

    if (defined($new_form) && !ref($new_form)) {
	# Handle overload for client_redirect
	$no_context = $new_path_info;
	$new_path_info = $new_form;
	$new_form = undef;
    }

    $new_query = Bivio::Agent::HTTP::Query->parse($new_query)
	    if defined($new_query) && !ref($new_query);
    # Now fill in the rest of the request context
    $self->put_durable(uri =>
	    # If there is no uri, use current one
	    Bivio::UI::Task->has_uri($new_task)
	    ? $self->format_uri($new_task, undef, $new_realm,
		    $new_path_info, $no_context) : $self->get('uri'),
	    query => $new_query,
	    form => $new_form,
	    form_model => undef,
	    path_info => $new_path_info,
	    form_context => $fc);
    return;
}

=for html <a name="internal_set_current"></a>

=head2 internal_set_current() : Bivio::Agent::Request

Called by subclasses when Request initialized.  Returns self.

=cut

sub internal_set_current {
    my($self) = @_;
    Bivio::Die->die($self, ': must be reference')
		unless ref($self);
    return $_CURRENT = $self;
}

=for html <a name="is_production"></a>

=head2 static is_production() : boolean

Returns I<is_production> from the configuration.

=cut

sub is_production {
    return $_IS_PRODUCTION;
}

=for html <a name="push_txn_resource"></a>

=head2 push_txn_resource(any resource)

Adds a new transaction resource to this request.  I<resource> must
support C<handle_commit> and C<handle_rollback>.

=cut

sub push_txn_resource {
    my($self, $resource) = @_;
    _trace($resource) if $_TRACE;
    push(@{$self->get('txn_resources')}, $resource);
    return;
}

=for html <a name="put_durable"></a>

=head2 put_durable(string key, string value, ...) : Bivio::Collection::Attributes

Puts durable attributes on the request.  A durable attribute survives
redirects.

=cut

sub put_durable {
    my($self) = shift;
    my($durable_keys) = $self->get_or_default('durable_keys', {});
    for (my ($i) = 0; $i < int(@_); $i += 2) {
	$durable_keys->{$_[$i]} = 1;
    }
    return $self->put(@_);
}

=for html <a name="server_redirect"></a>

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form, string new_path_info, boolean no_context)

=head2 server_redirect(Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, hash_ref new_form, string new_path_info, boolean no_context)

Server_redirect the current task to the new task.

B<DOES NOT RETURN.>

=cut

sub server_redirect {
    my($self, $new_task) = (shift, shift);
    $self->internal_server_redirect($new_task, @_);
    # clear db time
    Bivio::SQL::Connection->get_db_time;
    Bivio::Die->throw(Bivio::DieCode::SERVER_REDIRECT_TASK(),
	    {task_id => $new_task});
    return;
}

=for html <a name="server_redirect_in_handle_die"></a>

=head2 server_redirect_in_handle_die(Bivio::Die die, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, hash_ref new_query, hash_ref new_form, string new_path_info, boolean no_context)

=head2 server_redirect_in_handle_die(Bivio::Die die, Bivio::Agent::TaskId new_task, Bivio::Auth::Realm new_realm, string new_query, hash_ref new_form, string new_path_info, boolean no_context)

Same as L<server_redirect|"server_redirect">, but puts the attributes
on I<die> instead of executing L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub server_redirect_in_handle_die {
    my($self, $die, $new_task) = (shift, shift, shift);
    $self->internal_server_redirect($new_task, @_);
    $die->get('attrs')->{task_id} = $new_task;
    $die->put(code => Bivio::DieCode::SERVER_REDIRECT_TASK());
    return;
}

=for html <a name="set_current"></a>

=head2 set_current() : self

Sets current to I<self> and returns self.

=cut

sub set_current {
    return shift->internal_set_current();
}

=for html <a name="set_realm"></a>

=head2 set_realm(Bivio::Auth::Realm new_realm)

=head2 set_realm(Bivio::Biz::Model::RealmOwner new_realm)

=head2 set_realm(string realm_id_or_name)

Changes attributes to be authorized for I<new_realm>.  Also
sets C<auth_role>.

=cut

sub set_realm {
    my($self, $new_realm) = @_;
    $new_realm = Bivio::Auth::Realm->new($new_realm, $self)
	    unless UNIVERSAL::isa($new_realm, 'Bivio::Auth::Realm');
    my($realm_id) = $new_realm->get('id');
    my($new_role) = _get_role($self, $realm_id);
    $self->put_durable(auth_realm => $new_realm,
	    auth_id => $realm_id,
	    auth_role => $new_role);
    _trace($new_realm, '; ', $new_role) if $_TRACE;
    return;
}

=for html <a name="set_user"></a>

=head2 set_user(Bivio::Biz::Model::RealmOwner user)

=head2 set_user(string user_id_or_name)

B<Use
L<Bivio::Biz::Model::LoginForm|Bivio::Biz::Model::LoginForm>
to change users so the cookie gets updated.>
This is used to set the user temporarily and is called by
LoginForm, which manages the cookie as well.

In general, switching users should be limited to a small set of
classes.

Sets I<user> to be C<auth_user>.  May be C<undef>.  Also caches
user_realms.

B<Call this if you create/delete realms.>  It will refresh
the cached I<user_realms> list.

=cut

sub set_user {
    # dont_set_role is used internally, don't pass if outside this module.
    my($self, $user, $dont_set_role) = @_;
    $user = Bivio::Biz::Model::RealmOwner->new($self)
	    ->unauth_load_by_id_or_name_or_die($user, 'USER')
		    unless ref($user) || !defined($user);
    # DON'T CHECK CURRENT USER.  Always reread DB.
    my($user_realms);
    _trace($user) if $_TRACE;
    if ($user) {
	# Load the UserRealmList for this user.
	my($user_id) = $user->get('realm_id');
	my($list) = Bivio::Biz::Model->new($self, 'UserRealmList');
	$list->unauth_load_all({auth_id => $user_id});
#TODO: This may be quite expensive if lots of realms(?)
	$user_realms = $list->map_primary_key_to_rows;
    }
    else {
	$user_realms = {};
    }
    Bivio::Die->die($user, ': not a RealmOwner')
	    if defined($user) && !$user->isa('Bivio::Biz::Model');
    $self->put_durable(auth_user => $user,
	    auth_user_id => $user ? $user->get('realm_id') : undef,
	    user_realms => $user_realms);
    # Set the (cached) auth_role if requested (by default).
    $self->put_durable(auth_role => _get_role($self, $self->get('auth_id')))
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
    my($art) = $realm->get('type');
    # Normal case is for task and realm types to match, if not...
    if (defined($realm_id)) {
#TODO: Need to handle multiple realms, e.g. list of clubs to switch to
	$self->throw_die("not yet implemented");
    }
    unless ($trt eq $art) {
	$realm = _get_realm($self, $trt, $task_id);
	return 0 unless $realm;
    }
    return $realm->can_user_execute_task($task, $self);
}

=for html <a name="throw_die"></a>

=head2 static throw_die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

Terminate the request with a specific code.

=cut

sub throw_die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    $attrs ||= {};
    ref($attrs) eq 'HASH' || ($attrs = {attrs => $attrs});

    # Give some context to the error message
    my($realm, $task, $user) = $self->unsafe_get(
	    qw(auth_realm task_id auth_user));
    # Be a little more "safe" than usual, because we are in an
    # error situation.
    $attrs->{realm} = ref($realm) ? $realm->as_string : undef;
    $attrs->{task} = ref($task) ? $task->get_name : undef;
    $attrs->{user} = ref($user) ? $user->as_string : undef;

    Bivio::Die->throw($code, $attrs, $package, $file, $line);
}

=for html <a name="warn"></a>

=head2 warn(any args, ...)

Writes a warning and follows with the request context (task, user,
uri, query, form).

=cut

sub warn {
    my($self) = shift;
    return Bivio::IO::Alert->warn(@_, ' ', $self)
}

#=PRIVATE METHODS

# _form_for_warning(self) : string
#
# Returns the form sans secret and password fields fields.
#
sub _form_for_warning {
    my($self) = @_;
    my($form) = $self->unsafe_get('form');
    return undef unless $form;
    my($form_model) = $self->unsafe_get('form_model');
    return '<secure data>' if $form_model
	    && $form_model->get_info('has_secure_data');
    return $form;
}

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
	my($user_realms) = $self->get('user_realms');
	my($role, $realm_id) = Bivio::Auth::Role::UNKNOWN->as_int;
	foreach my $r (values(%$user_realms)) {
	    next unless $r->{'RealmOwner.realm_type'}
		    eq Bivio::Auth::RealmType::CLUB();
	    my($rr) = $r->{'RealmUser.role'}->as_int;
#TODO: Roles aren't necessarily ordered
	    next unless  $rr > $role;
	    $realm_id = $r->{'RealmUser.realm_id'};
	    $role = $rr;
	}
	return undef unless $realm_id;
	my($club) = Bivio::Biz::Model->new($self, 'RealmOwner');
#TODO: This will bomb if the realm disappeared since (cached) user_realms
#      was accessed.
	$club->unauth_load(realm_id => $realm_id);
	return Bivio::Auth::Realm->new($club);
    }
    if ($realm_type eq Bivio::Auth::RealmType::USER()) {
#TODO: Should this look in the user realm list?  This might point
#      to an arbitrary user?
	my($auth_user) = $self->get('auth_user');
	if ($auth_user) {
	    my($realm) = $self->unsafe_get('auth_user_realm');
	    unless ($realm) {
		$realm = Bivio::Auth::Realm->new($auth_user);
		$self->put_durable(auth_user_realm => $realm);
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

=head1 SEE ALSO

RFC2616 (HTTP/1.1), RFC1945 (HTTP/1.0), RFC1867 (multipart/form-data),
RFC2109 (Cookies), RFC1806 (Content-Disposition), RFC1521 (MIME)

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
