# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Request;
use strict;
use Bivio::Agent::HTTP::Query;
use Bivio::Agent::Task;
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Biz::FormModel;
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::UserAgent;

# C<Bivio::Agent::Request> Request provides a common interface for http,...
# requests to the application.  The transport specific
# Request implementation initializes most of these values
#
#
# During request processing, attributes are added to the Request object.
# Some attributes are models (by class name, see below).  Others are
# "standard", i.e. those shown below.  Yet others are task specific.
#
# Attributes specific to a task should be uniquely named so thery
# can be found easily in the code and to avoid name space collisions.
# They should be documented in the class which sets them under
# the B<REQUEST ATTRIBUTES> heading.  See, for example,
# L<Bivio::Biz::Model::FilePathList|Bivio::Biz::Model::FilePathList>.
#
# Task specific attributes should be avoided in general.  Try to
# put the state in a model, e.g. a FormModel or ListModel with local
# fields.
#
#
# auth_id : string
#
# Value of C<auth_realm->get('id')>.
#
# auth_realm : Bivio::Auth::Realm
#
# The realm in which the request operates.
#
# auth_role : Bivio::Auth::Role
#
# Role I<auth_user> is allowed to play in I<auth_realm>.
# Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.
#
# auth_user : Bivio::Biz::Model::RealmOwner
#
# The user authenticated with the request.
#
# auth_user_id : string
#
# The user id authenticated with the request.  Set before I<auth_user>
# as a part of cookie processing.
#
# Bivio::Type::UserAgent : Bivio::Type::UserAgent
#
# The type of the user agent for this request.
#
# can_secure : boolean
#
# Can this server function in secure mode?
#
# client_addr : string
#
# Client's network address if available.
#
# cookie : Bivio::Agent::Cookie
#
# This is the cookie that came in the HTTP header.  It may be
# C<undef> only if the protocol doesn't support cookies.
# Very few tasks should access the cookie directly.
# If at all possible, the hidden form fields and the query string should
# be used to maintain state.
#
# Any fields set in the request cookie will be set in the reply,
# i.e. there is only one cookie for request/reply.
# See L<Bivio::Agent::HTTP::Cookie|Bivio::Agent::HTTP::Cookie>
# for details.
#
# form : hash_ref
#
# Attributes in url-encoded POST body or other agent equivalent.
# Is C<undef>, if method was not POST or equivalent.
# NOTE: Forms must always have unique value names--still ok to
# use C<exists> or C<defined>.
#
# This value is initialized by FormModel, not by Request.
#
# initial_uri : string
#
# URI which came in with the request (sans facade, but including
# path_info).
#
# is_production : boolean
#
# Are we running in production mode?
#
# is_secure : boolean
#
# Are we running in secure mode (SSL)?
#
# path_info : string
#
# The dynamic part of the URI.   The name comes from CGI which defines
# a C<PATH_INFO> variable in scripts.  In our world, the dynamic part
# can be anywhere.  Treat C<undef> and the empty string identically.
#
# B<Always begins with C</> if defined.>  Unlike CGI, I<path_info> is
# not extracted from I<uri>.  I<path_info> is used to generate other
# URIs, not to recreate the existing one.
#
# B<It is not escaped.>  UI::Task and Biz::ListModel
# will escape it before appending.
#
# query : hash_ref
#
# Attributes in URI query string or other agent equivalent.
# Is C<undef>, if there are no query args--still ok to
# use C<exists> or C<defined>.
#
# NOTE: Query strings must always have unique value names.
#
# reply : Bivio::Agent::Reply
#
# L<Bivio::Agent::Reply|Bivio::Agent::Reply> for this request.
#
# request : Bivio::Agent::Request
#
# Always C<$self>.  Convenient for L<get_widget_value|"get_widget_value">.
#
# start_time : array_ref
#
# The time the request started as an array of seconds and microseconds.
# See L<Bivio::Type::DateTime->gettimeofday|Bivio::Util/"gettimeofday">.
#
# target_realm_owner : Bivio::Biz::Model::RealmOwner
#
# Set by L<Bivio::Biz::Action::TargetRealm|Bivio::Biz::Action::TargetRealm>.
# Used to allow a different realm to be operated on within the current
# realm.  Allows shareable code for AddressForm and such.
#
# You can use I<target_realm_owner> as an "authenticated" value, because
# C<TargetRealm> checks permissions properly.  Don't use "this" as
# an authenticated value.  See
# L<Bivio::UI::HTML::Club::UserDetail|Bivio::UI::HTML::Club::UserDetail>
# for an example when it loads C<TaxId>.
#
# task : Bivio::Agent::Task
#
# Tuple containing the Action and View to be executed.
# Set by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.
#
# task_id : Bivio::Agent::TaskId
#
# Same as I<task>'s I<id>.
#
# timezone : int
#
# The user's timezone (if available).  The timezone is an offsite in
# minutes from GMT.  See use in
# L<Bivio::Type::DateTime|Bivio::Type::DateTime>.
#
# txn_resources : array_ref
#
# The list of resources (objects) which have transaction handlers
# (handle_commit and handle_rollback).  The handlers are called before
# any commit or rollback.
#
# Handlers are called and cleared by L<Bivio::Agent::Task|Bivio::Agent::Task>.
#
# user_state : Bivio::Type::UserState
#
# Is the user just a visitor, logged in, or out?  Set by LoginForm.
#
# uri : string
#
# URI from the incoming request unmodified.  It is already "escaped".
#
# E<lt>ModuleE<gt> : Bivio::UNIVERSAL
#
# Maps I<E<lt>ModuleE<gt>> to an instance of that modules.  Facade, Actions
# and Views will put instances as they are initialized on to the request.
# If there is an owner to the I<auth_realm>, this will be the first
# L<Bivio::Biz::Model|Bivio::Biz::Model> added to the request.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# We don't import any UI components here, because they are
# initialized by Bivio::Agent::Dispatcher
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_IS_PRODUCTION) = 0;
my($_CAN_SECURE);
Bivio::IO::Config->register({
    is_production => $_IS_PRODUCTION,
    can_secure => 1,
});
my($_CURRENT);

sub FORMAT_URI_PARAMETERS {
    # Order and names of params passed to format_uri().
    return [qw(task_id query realm path_info no_context anchor require_context uri)];
}

sub as_string {
    my($self) = @_;
    # Returns the important request context as a string.  Items currently
    # returned: task, user, referer, uri, query, and form.
    my($r) = $self->unsafe_get('r');
    my($t) = $self->unsafe_get('task_id');
    return 'Request['.Bivio::IO::Alert->format_args(
	    'task=', $t ? $t->get_name : undef,
	    ' user=', $self->unsafe_get_nested(qw(auth_user name))
		|| $r && $r->connection->user,
	    ' realm=',
	        ($self->unsafe_get_nested(qw(auth_realm owner_name))
		|| ($self->unsafe_get('auth_realm')
                    ? $self->get_nested(qw(auth_realm type))->get_name
                    : undef)),
	    ' referer=', $r ? $r->header_in('Referer') : undef,
	    ' uri=', $self->unsafe_get('uri'),
	    ' query=', $self->unsafe_get('query'),
	    ' form=', _form_for_warning($self),
	   ).']';
}

sub can_user_execute_task {
    my($self, $task_name, $realm_id) = @_;
    # Convenience routine which executes
    # L<Bivio::Auth::Realm::can_user_execute_task|Bivio::Auth::Realm/"can_user_execute_task">
    # for the I<auth_realm> or one that matches the realm_type of the task
    # and current I<auth_user>.
    # I<task> may be a task name or Bivio::Agent::TaskId.
    # I<realm_id> may be a realm_id or realm name.
    my($task) = Bivio::Agent::Task->get_by_id(
        Bivio::Agent::TaskId->from_any($task_name));
    my($realm);

    if ($realm_id) {
        $realm = Bivio::Auth::Realm->new($realm_id, $self);
        Bivio::Die->die('supplied realm\'s realm_type does not match task: ',
            $task->get('id')->get_name)
            unless $task->get('realm_type') == $realm->get('type');
    }
    else {
        $realm = $self->internal_get_realm_for_task($task->get('id'));
    }
    return $realm
        ? $realm->can_user_execute_task($task, $self)
        : 0;
}

sub clear_current {
    # Clears the state of the current request.  See L<get_current|"get_current">.
    return unless $_CURRENT;
    # This breaks any circular references, so AGC can work
    $_CURRENT->delete_all;
    $_CURRENT->internal_clear_current;
    return;
}

sub clear_nondurable_state {
    my($self) = @_;
    # Clears out models (Bivio::Biz::*) and any other nondurable state.  This
    # method will be expanded over time.
    my($durable_keys) = $self->get('durable_keys');
    my(@non_durable_keys) = map { $durable_keys->{$_} ? () : $_ }
	    @{$self->get_keys};
    _trace("durable keys: ".join(',', keys(%$durable_keys))) if $_TRACE;
    _trace("NON durable keys: ".join(',', @non_durable_keys)) if $_TRACE;
    $self->delete(@non_durable_keys);
    return;
}

sub client_redirect {
    my($self, $named) = shift->internal_get_named_args(
    # Pass in parameters I<named> below.
    #
    #
    # Redirects the client to the location of the specified new_task. By default,
    # this uses L<redirect|"redirect">, but subclasses (HTTP) should override this
    # to force a hard redirect.
    #
    # B<DOES NOT RETURN>.
	[qw(task_id realm hash_ref query path_info no_context require_context no_form)],
	\@_);
    return $self->server_redirect($named);
}

sub clone {
    # We don't clone the request object, because it is a singleton.
    return shift;
}

sub elapsed_time {
    my($self) = @_;
    # Returns the number of seconds elapsed since the request was created.
    return Bivio::Type::DateTime->gettimeofday_diff_seconds(
	    $self->get('start_time'));
}

sub format_email {
    my($self, $email) = @_;
    # Formats the email address for inclusion in a mail header.
    # If the host is missing, adds I<Text.mail_host>.
#TODO: Properly quote the email name???
    # Will bomb if no auth_realm.
    return $self->get('auth_realm')->format_email
	unless defined($email);
    return $email
	if $email =~ /\@/;
    my($f) =  $self->unsafe_get('Bivio::UI::Facade');
    return $f->get('Email')->format($email)
        if $f && $f->unsafe_get('Email');
    return $email . '@' . Sys::Hostname::hostname();
}

sub format_help_uri {
    my($self, $task_id) = @_;
    # Formats the uri for I<task_id> (defaults to task_id on request).  If the task
    # doesn't have a help entry, defaults to default help page.
    #
    # I<task_id> may be a widget value, string (the name), or
    # a L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.
    $task_id = $task_id ? ref($task_id) ? $task_id
	: Bivio::Agent::TaskId->from_any($task_id)
	: $self->get('task_id');
    return Bivio::UI::Task->format_help_uri($task_id, $self);
}

sub format_http {
    my($self) = shift;
    # Creates an http URI.  See L<format_uri|"format_uri"> for argument descriptions.
    #
    # Handles I<require_secure> according to rules in L<format_uri|"format_uri">.
    # Must be @_ so format_uri handles overloading properly
    my($uri) = $self->format_uri(@_);
    return $uri =~ /^\w+:/ ? $uri : $self->format_http_prefix.$uri;
}

sub format_http_insecure {
    my($self) = shift;
    # Creates an http URI.  Forces http not https.  See L<format_uri|"format_uri"> for argument descriptions.
    # Must be @_ so format_uri handles overloading properly
    my($uri) = $self->format_uri(@_);
    return $uri if $uri =~ s/^https:/http:/;
    return 'http://' . Bivio::UI::Facade->get_value('http_host', $self) . $uri;
}

sub format_http_prefix {
    my($self, $require_secure) = @_;
    # Returns the http or https prefix for this I<Text.http_host>.  Does not add
    # trailing '/'.
    #
    # You should pass in the I<require_secure> value for the task you are
    # rendering for.
    # If is_secure is not set, default to non-secure
    return ($self->unsafe_get('is_secure') || $require_secure
	    ? 'https://' : 'http://')
	    . Bivio::UI::Facade->get_value('http_host', $self);
}

sub format_mailto {
    my($self, $email, $subject) = @_;
    # Creates a mailto URI.  If I<email> is C<undef>, set to
    # I<auth_realm> owner's name.   If I<email> is missing a host, uses
    # I<Text.mail_host>.
    my($res) = 'mailto:'
	    . Bivio::HTML->escape_uri($self->format_email($email));
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

sub format_stateless_uri {
    my($self, $task_id) = @_;
    # Creates a URI relative to this host/port/realm without a query string.
    return $self->format_uri({
	task_id => $task_id,
	query => undef,
	realm => undef,
	path_info => undef,
    });
}

sub format_uri {
    # Pass in parameters in a hash I<named>.  This is preferred format for anything
    # complicated.
    #
    #
    # Creates a URI relative to this host:port
    # If I<query> is C<undef>, will not create a query string.
    # If I<query> is not passed, will use this request's query string.
    # If the task doesn't I<want_query>, will not append query string.
    # If the task does I<require_secure>, will prefix https: unless
    # the page is already secure.
    # If I<realm> is C<undef>, request's realm will be used.
    # If I<path_info> is C<undef>, request's path_info will be used.
    #
    # If the task doesn't have a uri, dies.
    #
    # I<anchor> will be appended last.
    #
    # I<no_context> and I<require_context> as described by
    # L<Bivio::UI::Task::format_uri|Bivio::UI::Task/"format_uri">.
    my($self) = shift;
    my($named);
    ($self, $named) = $self->internal_get_named_args(
	$self->FORMAT_URI_PARAMETERS,
	\@_);
    my($uri);
    unless (defined($uri = $named->{uri})) {
	foreach my $x (qw(task_id path_info query)) {
	    $named->{$x} = $self->unsafe_get($x)
		unless exists($named->{$x});
	}
	$named->{realm} = $self->internal_get_realm_for_task($named->{task_id})
	    unless defined($named->{realm});
	$uri = Bivio::UI::Task->format_uri($named, $self);
	my($task) = Bivio::Agent::Task->get_by_id($named->{task_id});
	$uri = $self->format_http_prefix(1) . $uri
	    if $task->get('require_secure') && !$self->unsafe_get('is_secure')
		&& $self->get('can_secure');
	delete($named->{query})
	    unless $task->get('want_query');
    }
    if (defined($named->{query})) {
        $named->{query} = Bivio::Agent::HTTP::Query->format($named->{query})
            if ref($named->{query});
        $uri =~ s/\?/?$named->{query}&/ || ($uri .= '?'.$named->{query})
	    if length($named->{query});
    }
    $uri .= '#' . Bivio::HTML->escape_query($named->{anchor})
        if defined($named->{anchor}) && length($named->{anchor});
    return $uri;
}

sub get_auth_role {
    # Returns auth role for I<realm>.
    return shift->get_auth_roles(@_)->[0];
}

sub get_auth_roles {
    my($self, $realm) = @_;
    # Returns auth roles for I<realm>.
    $realm ||= $self->get('auth_realm');
    my($realm_id) = ref($realm) ? $realm->get('id') : $realm;
    my($auth_id, $auth_roles) = $self->unsafe_get(qw(auth_id auth_roles));

    # Use (cached) value in $self if realm_id is the same.  Otherwise,
    # go through entire lookup process.
    return $auth_id eq $realm_id ? $auth_roles : _get_roles($self, $realm_id);
}

sub get_content {
    # Returns undef.
    return undef;
}

sub get_current {
    # Returns the current Request being processed.  To clear the state
    # of the current request, use L<clear_current|"clear_current">.
    return $_CURRENT;
}

sub get_current_or_new {
    my($proto) = @_;
    # Returns the current request or creates as new one.  To be used
    # for utilities.
    my($current) = $proto->get_current;
    return $current if $current;
    return $proto->internal_new->internal_set_current
	if $proto eq __PACKAGE__;
    return $proto->new;
}

sub get_field {
    my($self, $attr, $name) = @_;
    # Returns the field of I<attr> specified by I<name>.  Missing
    # fields are allowed and are returned as C<undef>. If I<attr>
    # is undefined, returns undef.
    $attr = $self->unsafe_get($attr);
    return ref($attr) ? $attr->{$name} : undef;
}

sub get_fields {
    my($self, $attr, $names) = @_;
    # Returns the fields of I<attr> specified by I<names>.  Missing
    # fields are allowed and are returned as C<undef>. If I<attr>
    # is undefined, returns the empty hash.
    $attr = $self->unsafe_get($attr);
    return {} unless ref($attr);
    return {map {
	($_, $attr->{$_});
    } @$names};
}

sub get_form {
    # Returns undef.
    return undef;
}

sub get_form_context_from_named {
    my($self, $named) = @_;
    # Used to communicate between L<Bivio::UI::Task|Bivio::UI::Task>,
    # L<Bivio::Agent::Task|Bivio::Agent::Task>, and this class.  You don't want to
    # call this.
    my($fc);
    # If the task we are going to is the same as the unwind task,
    # don't render the context.  Prevents infinite recursion.
    # If we don't have an unwind task, we don't return a context
    return $named->{form_context} =
        ($named->{require_context}
	    || !$named->{no_context}
            && Bivio::Agent::Task->get_by_id($named->{task_id})
		->get('require_context')
	) && ($fc = exists($named->{form_context}) ? $named->{form_context}
		  : Bivio::Biz::FormModel->get_context_from_request(
		      $named, $self)
#THIS MAY BE DUBIOUS
	) && ($fc->unsafe_get('unwind_task') || '') ne $named->{task_id}
        ? $fc : undef;
}

sub get_request {
    my($proto) = @_;
    # Returns I<self> if not called statically, else returns
    # I<get_current_or_new>.
    #
    # Called I<get_request> so callers don't have to worry about getting
    # request from non-Biz::Model sources.  Calling I<get_request> always
    # works on I<$source>.
    return ref($proto) ? $proto : $proto->get_current_or_new;
}

sub handle_config {
    my(undef, $cfg) = @_;
    # Host name configuration. Override this to proxy to another host.
    #
    #
    # can_secure : boolean [1]
    #
    # Only used for development systems (single server mode), which can't
    # run in secure mode.
    #
    # is_production : boolean [false]
    #
    # Are we running in production mode?
    $_IS_PRODUCTION = $cfg->{is_production};
    $_CAN_SECURE = $cfg->{can_secure};
    return;
}

sub internal_clear_current {
    # B<DO NOT CALL THIS UNLESS YOU KNOW WHAT YOU ARE DOING.>
    $_CURRENT = undef;
    return;
}

sub internal_get_named_args {
    my(undef, $names, $argv) = @_;
    # Calls name_parameters in L<Bivio::UNIVERSAL|Bivio::UNIVERSAL> then
    # converts I<task_id> to a L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.
    my($self, $named) = shift->name_parameters(@_);
    $named->{task_id} = !$named->{task_id} ? $self->get('task_id')
	: UNIVERSAL::isa($named->{task_id}, 'Bivio::Agent::TaskId')
	? $named->{task_id}
	: Bivio::Agent::TaskId->from_name($named->{task_id})
	if grep($_ eq 'task_id', @$names);
    _trace((caller(1))[3], $named) if $_TRACE;
    return ($self, $named);
}

sub internal_get_realm_for_task {
    my($self, $task_id) = @_;
    # Returns the realm for the specified task.  If the realm type of the
    # task matches the current realm, current realm is returned.
    #
    # B<Deprecated> Otherwise, we return the best realm that matches the type of
    # the task.
    # If is current task, just return current realm.
    my($realm) = $self->get('auth_realm');
    _trace('current auth_realm is: ', $realm->get('id'))
	if $_TRACE;
    return $realm if $task_id == $self->get('task_id');
    my($trt) = Bivio::Agent::Task->get_by_id($task_id)->get('realm_type');
    return $realm if $trt == $realm->get('type');
    return Bivio::Auth::Realm->get_general
	if $trt->equals_by_name('GENERAL');

    # Use auth_user if the target realm is USER
    if ($trt->equals_by_name('USER')) {
	my($auth_user) = $self->get('auth_user');
	if ($auth_user) {
	    my($realm) = $self->unsafe_get('auth_user_realm');
	    unless ($realm) {
		$realm = Bivio::Auth::Realm->new($auth_user);
		$self->put_durable(auth_user_realm => $realm);
	    }
	    return $realm;
	}
	return undef;
    }

#TODO: remove this section and die at some point
#      it makes incorrect assumptions about role order
#      rjn 11/26/06 might be able to make work by asking if have permissions
#      for the target realm type required by task.
    Bivio::IO::Alert->warn_deprecated(
	$task_id, ': use explicit realm');

    my($role) = Bivio::Auth::Role->UNKNOWN->as_int;
    my($realm_id);
    $self->map_user_realms(sub {
        my($realm) = @_;
        my($rr) = $realm->{'RealmUser.role'}->as_int;
        return unless  $rr > $role;
        $realm_id = $realm->{'RealmUser.realm_id'};
        $role = $rr;
    }, {
	'RealmOwner.realm_type' => $trt,
    });
    return $realm_id
        ? Bivio::Auth::Realm->new($realm_id, $self)
        : undef;
}

sub internal_initialize {
    my($self, $auth_realm, $auth_user) = @_;
    # Called by subclass after it has initialized all state.
    $self->set_user($auth_user);
    $self->set_realm($auth_realm);
    return $self;
}

sub internal_new {
    my($proto, $attributes) = @_;
    # B<Don't call unless you are a subclass.>
    # Use L<get_current_or_new|"get_current_or_new">.
    #
    # Creates a request with initial I<attributes>.
    #
    # Subclasses must call L<internal_set_current|"internal_set_current">
    # when the instance is sufficiently initialized.
    #
    # I<attributes> is put_durable.
    my($self) = $proto->SUPER::new({durable_keys => {durable_keys => 1}});
    $self->put_durable(
	# Initial keys 
	%$attributes,
	request => $self,
	is_production => $_IS_PRODUCTION,
	txn_resources => [],
	can_secure => $_CAN_SECURE,
    );
    # Make sure a value gets set
    Bivio::Type::UserAgent->execute_unknown($self);
    _trace($self) if $_TRACE;
    return $self;
}

sub internal_redirect_realm {
    my($self, $new_task, $new_realm) = @_;
    # Changes the current realm if required by the new task.
    my($fields) = $self->[$_IDI];
    my($task) = Bivio::Agent::Task->get_by_id($new_task);

    my($trt) = $task->get('realm_type');
    if ($new_realm) {
	# Assert param
	my($nrt) = $new_realm->get('type');
	Bivio::Die->die($new_task->as_string, ' realm_type mismatch (',
		$trt->get_name, ' != ', $nrt, ')') unless $trt eq $nrt;
    }
    elsif (!defined($new_realm = $self->internal_get_realm_for_task($new_task))) {
	$new_realm = $self->internal_redirect_realm_guess($trt);
    }
    # Change realms before formatting uri
    $self->set_realm($new_realm) if $new_realm;
    $self->put(
        task_id => $new_task,
        task => Bivio::Agent::Task->get_by_id($new_task),
    );
    return;
}

sub internal_redirect_realm_guess {
    my($self, $target) = @_;
    # Redirects based on I<target>
#TODO: We should not guess here, but blow up
    # Need to login as a user.
    $self->server_redirect(Bivio::Agent::TaskId->LOGIN)
	if $target eq Bivio::Auth::RealmType->USER;
    # GO TO HOME instead of a club.  He can choose realm chooser
    $self->client_redirect(Bivio::Agent::TaskId->USER_HOME);
    # DOES NOT RETURN
}

sub internal_server_redirect {
    my($self, $named) = shift->internal_get_named_args(
    # Sets all values and saves form context.  See L<format_uri|"format_uri"> for the
    # arguments.
	[qw(task_id realm query form path_info no_context require_context no_form)],
	\@_);
    Bivio::UI::Task->assert_defined_for_facade($named->{task_id}, $self);
    my($fc) = Bivio::Biz::FormModel->get_context_from_request($named, $self);
    $self->internal_redirect_realm($named->{task_id}, $named->{realm});
    $named->{query} = $self->get('query')
	if !exists($named->{query})
	&& Bivio::Agent::Task->get_by_id($named->{task_id})->get('want_query');
    $named->{query} = Bivio::Agent::HTTP::Query->format($named->{query})
	if ref($named->{query});
    $named->{query} = defined($named->{query})
	? Bivio::Agent::HTTP::Query->parse($named->{query}) : undef;
    $named->{uri} = Bivio::UI::Task->has_uri($named->{task_id})
	? $self->format_uri({
	    map((exists($named->{$_}) ? ($_ => $named->{$_}) : ()),
		@{$self->FORMAT_URI_PARAMETERS}),
        }) : $self->get('uri');
    $named->{form_context} = $fc;
    foreach my $x (qw(form path_info)) {
	$named->{$x} = undef
	    unless exists($named->{$x});
    }
    $self->put_durable_server_redirect_state($named);
    return $named->{task_id};
}

sub internal_set_current {
    my($self) = @_;
    # Called by subclasses when Request initialized.  Returns self.
    Bivio::Die->die($self, ': must be reference')
	unless ref($self);
    Bivio::IO::Alert->warn('replacing request:', $self->get_current)
        if $self->get_current;
    return $_CURRENT = $self;
}

sub is_production {
    # Returns I<is_production> from the configuration.
    return $_IS_PRODUCTION;
}

sub is_substitute_user {
    # Returns true if the user is a substituted user.
    return shift->unsafe_get('super_user_id') ? 1 : 0;
}

sub is_super_user {
    my($self, $user_id) = @_;
    # Returns true if I<user_id> is a super user.  If I<user_id> is undef,
    # uses Request.auth_user_id.
    return !$user_id
	|| (defined($user_id) eq defined($self->get('auth_user_id'))
	    && $user_id eq $self->get('auth_user_id'))
	? _get_role($self, Bivio::Auth::RealmType->GENERAL->as_int)
	    ->equals_by_name('ADMINISTRATOR')
	: Bivio::Biz::Model->new($self, 'RealmUser')->unauth_load({
	    realm_id => Bivio::Auth::RealmType->GENERAL->as_int,
	    user_id => $user_id,
	    role => Bivio::Auth::Role->ADMINISTRATOR,
	});
}

sub is_test {
    # Opposite of L<is_production|"is_production">.
    return shift->is_production(@_) ? 0 : 1;
}

sub map_user_realms {
    my($self, $op, $filter) = @_;
    # Calls I<op> with each row UserRealmList as a hash sorted by RealmOwner.name.
    # If no I<op>, returns row.  If I<filter> supplied, only supplies rows
    # which match filter.
    #
    # B<Use of $self-E<gt>get_user_realms is deprecated>.
    $op ||= sub {shift(@_)};
    my($atomic_copy) = [
	map(+{%$_},
	    sort(
		{$a->{'RealmOwner.name'} cmp $b->{'RealmOwner.name'}}
	        grep({
		    my($x) = $_;
		    !$filter ||
			keys(%$filter)
			== grep($filter->{$_} eq $x->{$_}, keys(%$filter));
		} values(%{$self->get('user_realms')}))))];
    return [map($op->($_), @$atomic_copy)];
}

sub new {
    # B<Terminates caller.>  Use L<get_current_or_new|"get_current_or_new">.
    die('only can initialize from subclasses');
}

sub process_cleanup {
    my($self, $die) = @_;
    # Calls any cleanup outside of the database commit/rollback.
    return unless $self->unsafe_get('process_cleanup')
        && @{$self->get('process_cleanup')};
    my($is_ok) = 1;

    foreach my $cleaner (@{$self->get('process_cleanup')}) {
        if (Bivio::Die->catch(
            sub {
                $cleaner->($self, $die);
            })
        ) {
            $is_ok = 0;
        }
    }
    $is_ok
        ? Bivio::Agent::Task->commit($self)
        : Bivio::Agent::Task->rollback($self);
    return;
}

sub push_txn_resource {
    my($self, $resource) = @_;
    # Adds a new transaction resource to this request.  I<resource> must
    # support C<handle_commit> and C<handle_rollback>.
    _trace($resource) if $_TRACE;
    push(@{$self->get('txn_resources')}, $resource);
    return;
}

sub put_durable {
    my($self) = shift;
    # Puts durable attributes on the request.  A durable attribute survives
    # redirects.
    my($durable_keys) = $self->get('durable_keys');
    for (my ($i) = 0; $i < int(@_); $i += 2) {
	$durable_keys->{$_[$i]} = 1;
    }
    return $self->put(@_);
}

sub put_durable_server_redirect_state {
    my($self, $named) = @_;
    # You should use L<server_redirect|"server_redirect">, not this routine.
    #
    # Used to set state for server redirect.  Handles form_context specially.
    $self->put_durable(
	map((exists($named->{$_}) ? ($_ => $named->{$_}) : ()),
	    qw(query form form_model path_info uri)),
	form_context => $self->get_form_context_from_named($named),
    );
    return;
}

sub server_redirect {
    my($task) = shift->internal_server_redirect(@_);
    # Server_redirect the current task to the new task.
    #
    # See L<format_uri|"format_uri"> for args.
    #
    # B<DOES NOT RETURN.>
    # clear db time
    Bivio::SQL::Connection->get_db_time;
    Bivio::Die->throw_quietly(
	Bivio::DieCode->SERVER_REDIRECT_TASK,
	{task_id => $task},
    );
    # DOES NOT RETURN
}

sub set_current {
    # Sets current to I<self> and returns self.
    return shift->internal_set_current();
}

sub set_realm {
    my($self, $new_realm) = @_;
    # Changes attributes to be authorized for I<new_realm>.  Also
    # sets C<auth_role>.  Returns the realm.
    $new_realm = defined($new_realm)
	? Bivio::Auth::Realm->new($new_realm, $self)
	: Bivio::Auth::Realm->get_general
	unless $self->is_blessed($new_realm, 'Bivio::Auth::Realm');
    my($realm_id) = $new_realm->get('id');
    my($new_role) = _get_role($self, $realm_id);
    my($new_roles) = _get_roles($self, $realm_id);
    $self->put_durable(
	auth_realm => $new_realm,
	auth_id => $realm_id,
	auth_role => $new_role,
	auth_roles => $new_roles,
    );
    _trace($new_realm, '; ', $new_roles) if $_TRACE;
    return $new_realm;
}

sub set_user {
    my($self, $user) = @_;
    # B<Use
    # L<Bivio::Biz::Model::LoginForm|Bivio::Biz::Model::LoginForm>
    # to change users so the cookie gets updated.>
    # This is used to set the user temporarily and is called by
    # LoginForm, which manages the cookie as well.
    #
    # In general, switching users should be limited to a small set of
    # classes.
    #
    # Sets I<user> to be C<auth_user>.  May be C<undef>.  Also caches
    # user_realms.
    #
    # B<Call this if you create/delete realms.>  It will refresh
    # the cached I<user_realms> list.
    #
    # Returns I<auth_user>, which my be C<undef>.
    # We don't set the role if there's not auth_realm
    my($dont_set_role) = $self->unsafe_get('auth_realm') ? 0 : 1;
    $user = Bivio::Biz::Model->new($self, 'RealmOwner')
	->unauth_load_by_id_or_name_or_die($user, 'USER')
        unless ref($user) || !defined($user);
    # DON'T CHECK CURRENT USER.  Always reread DB.
    my($user_realms);
    _trace($user) if $_TRACE;
    if ($user) {
	# Load the UserRealmList for this user.
	my($list) = Bivio::Biz::Model->new($self, 'UserRealmList');
	$list->unauth_load_all({auth_id => $user->get('realm_id')});
	$user_realms = $list->map_primary_key_to_rows;
    }
    else {
	$user_realms = {};
    }
    Bivio::Die->die($user, ': not a RealmOwner')
        if defined($user) && !$user->isa('Bivio::Biz::Model');
    $self->put_durable(
	auth_user => $user,
	auth_user_id => $user ? $user->get('realm_id') : undef,
	user_realms => $user_realms,
    );
    # Set the (cached) auth_role if requested (by default).
    $self->put_durable(
        auth_role => _get_role($self, $self->get('auth_id')),
        auth_roles => _get_roles($self, $self->get('auth_id')),
    )
	unless $dont_set_role;
    return $user;
}

sub throw_die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    # Terminate the request with a specific code.
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
    # DOES NOT RETURN
}

sub unsafe_get_txn_resource {
    my($self, $class) = @_;
    # Gets the transaction resource which implements I<class> on the
    # request.  If multiple resources found, blows up.   Must only be used
    # by singleton resources.  If none found, returns undef.
    my($res)
	= [grep(UNIVERSAL::isa($_, $class), @{$self->get('txn_resources')})];
    $self->throw_die(DIE => {
	message => 'too many transaction resources found',
	entity => $res,
	class => $class,
    }) if @$res > 1;
    return $res->[0];
}

sub warn {
    my($self) = shift;
    # Writes a warning and follows with the request context (task, user,
    # uri, query, form).
    return Bivio::IO::Alert->warn(@_, ' ', $self)
}

sub with_realm {
    # Calls set_realm(realm) and then op.   Restores prior realm, even on exception.
    # Returns what I<op> returns (in array context always).
    return _with(realm => @_);
}

sub with_user {
    # Calls set_user(user) and then op.   Restores prior user, even on exception.
    # Returns what I<op> returns (in array context always).
    return _with(user => @_);
}

sub _form_for_warning {
    my($self) = @_;
    # Returns the form sans secret and password fields fields.
    my($form, $form_model) = $self->unsafe_get(qw(form form_model));
    return $form unless $form && $form_model
        && $form_model->get_info('has_secure_data');
    my($result) = {%$form};

    foreach my $field (@{$form_model->get_keys}) {
        next unless $form_model->has_fields($field);
        next unless $form_model->get_field_type($field)->is_secure_data;
        # hide the secure data from the logs if defined
        my($html_name) = $form_model->get_field_name_for_html($field);
        $result->{$html_name} = '<secure data>'
            if defined($result->{$html_name});
    }
    return $result;
}

sub _get_role {
    # Does the work for get_auth_role().
    return _get_roles(@_)->[0];
}

sub _get_roles {
    my($self, $realm_id) = @_;
    # Does the work for get_auth_roles().
    my($auth_user, $user_realms) = $self->unsafe_get(
        qw(auth_user user_realms));

    # If no user, then is always anonymous
    return [Bivio::Auth::Role->ANONYMOUS] unless $auth_user;

    # Not the current realm, but an authenticated realm
    return $user_realms->{$realm_id}->{roles}
        if ref($user_realms->{$realm_id});

    # User has no special privileges in realm
    return [Bivio::Auth::Role->USER];
}

sub _with {
    my($which, $self, $with_value, $op) = @_;
    my($prev) = $self->get("auth_$which");
    my($set) = "set_$which";
    my(@res);
    my($die) = Bivio::Die->catch(sub {
        $self->$set($with_value);
	@res = $op->();
	return;
    });
    $self->$set($prev);
    $die->throw
	if $die;
    return @res;

}

1;
