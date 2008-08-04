# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved
# $Id$
package Bivio::Agent::Request;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;

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
my($_C) = b_use('SQL.Connection');
my($_D) = b_use('Bivio.Die');
my($_DC) = b_use('Bivio.DieCode');
my($_DT) = b_use('Type.DateTime');
my($_FCT) = b_use('FacadeComponent.Task');
my($_FM) = b_use('Biz.FormModel');
my($_HTML) = b_use('Bivio.HTML');
my($_Q) = b_use('AgentHTTP.Query');
my($_REALM) = b_use('Auth.Realm');
my($_ROLE) = b_use('Auth.Role');
my($_RT) = b_use('Auth.RealmType');
my($_T) = b_use('Agent.Task');
my($_TI) = b_use('Agent.TaskId');
my($_UA) = b_use('Type.UserAgent');
my($_V7) = b_use('IO.Config')->if_version(7);
Bivio::IO::Config->register(my $_CFG = {
    is_production => 0,
    can_secure => 1,
});
my($_CURRENT);

sub FORMAT_URI_PARAMETERS {
    # Order and names of params passed to format_uri().
    return [qw(task_id query realm path_info no_context anchor require_context uri form_in_query require_absolute carry_query carry_path_info)];
}

sub FORM_IN_QUERY_FLAG {
    return 'form_post';
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

sub assert_http_method {
    my($self, $method) = @_;
    $self->throw_die(INVALID_OP => {
	message => "must be $method",
    }) unless $self->is_http_method($method);
    return $self;
}

sub assert_test {
    my($self) = @_;
    $self->throw_die(DIE => {message => 'may not be run on production'})
	if $self->is_production;
    return $self;
}

sub can_secure {
    return $_CFG->{can_secure};
}

sub can_user_execute_task {
    my($self, $task_name, $realm) = @_;
    my($tid) = $_TI->from_any($task_name);
    return 0
	if $_V7
	&& !$_FCT->is_defined_for_facade($tid->get_name, $self);
    my($task) = $_T->get_by_id($tid);
    if ($realm) {
        $realm = Bivio::Auth::Realm->new($realm, $self);
	$task->assert_realm_type($realm->get('type'));
    }
    else {
        $realm = $self->internal_get_realm_for_task($tid);
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
    my($dk) = $self->get('durable_keys');
    my($ndk) = [grep(!$dk->{$_}, @{$self->get_keys})];
    $self->delete(@$ndk);
    if ($_TRACE) {
	_trace('retained: ', [sort(keys(%$dk))]);
	_trace('deleted: ', [sort(@$ndk)]);
    }
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
	[qw(task_id realm query path_info no_context require_context no_form uri carry_query carry_path_info)],
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
    return $_DT->gettimeofday_diff_seconds($self->get('start_time'));
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
    # a L<$_TI|$_TI>.
    $task_id = $task_id ? ref($task_id) ? $task_id
	: $_TI->from_any($task_id)
	: $self->get('task_id');
    return $_FCT->format_help_uri($task_id, $self);
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
	    . $_HTML->escape_uri($self->format_email($email));
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
	carry_query => 0,
	carry_path_info => 0,
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
    # L<$_FCT::format_uri|$_FCT/"format_uri">.
    my($self) = shift;
    my($named);
    ($self, $named) = $self->internal_get_named_args(
	$self->FORMAT_URI_PARAMETERS,
	\@_);
    return $self->format_http($named)
	if delete($named->{require_absolute});
    my($uri);
    b_die($named, ': must supply query with form_in_query')
        if $named->{form_in_query} && ref($named->{query}) ne 'HASH';
    if (defined($uri = $named->{uri})) {
	b_die($named, ': require secure not supported')
	    if defined($named->{require_secure});
	$named->{no_context} = 1
	    unless defined($named->{no_context})
	    || defined($named->{require_context});
	$named->{uri} = $uri;
	$self->internal_copy_implicit($named);
	$uri = $_FCT->format_uri($named, $self);
    }
    else {
	$named->{task_id} = $self->unsafe_get('task_id')
	    unless exists($named->{task_id});
	$self->internal_copy_implicit($named);
	$named->{realm} = $self->internal_get_realm_for_task($named->{task_id})
	    unless defined($named->{realm});
	$uri = $_FCT->format_uri($named, $self);
	my($task) = $_T->get_by_id($named->{task_id});
	$uri = $self->format_http_prefix(1) . $uri
	    if $task->get('require_secure') && !$self->unsafe_get('is_secure')
		&& $self->get('can_secure');
    }
    if (defined($named->{query})) {
	$named->{query}->{$self->FORM_IN_QUERY_FLAG} = 1
	    if $named->{form_in_query};
        $named->{query} = $_Q->format($named->{query})
            if ref($named->{query});
        $uri =~ s/\?/?$named->{query}&/ || ($uri .= '?'.$named->{query})
	    if length($named->{query});
    }
    $uri .= '#' . $_HTML->escape_query($named->{anchor})
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
    return shift->unsafe_get('content');
}

sub get_current {
    # Returns the current Request being processed.  To clear the state
    # of the current request, use L<clear_current|"clear_current">.
    return $_CURRENT;
}

sub get_current_or_die {
    return shift->get_current || die('no request');
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
    # Used to communicate between L<$_FCT|$_FCT>,
    # L<$_T|$_T>, and this class.  You don't want to
    # call this.
    my($fc);
    # If the task we are going to is the same as the unwind task,
    # don't render the context.  Prevents infinite recursion.
    # If we don't have an unwind task, we don't return a context
    return $named->{form_context} =
        ($named->{require_context}
	    || !$named->{no_context}
            && $_T->get_by_id($named->{task_id})
		->get('require_context')
	) && ($fc = exists($named->{form_context}) ? $named->{form_context}
		  : $_FM->get_context_from_request(
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
    $_CFG = $cfg;
    return;
}

sub internal_clear_current {
    # B<DO NOT CALL THIS UNLESS YOU KNOW WHAT YOU ARE DOING.>
    $_CURRENT = undef;
    return;
}

sub internal_copy_implicit {
    my($self, $named) = @_;
    foreach my $a (qw(query path_info)) {
	if ($a eq 'query' && $named->{task_id}
	    && !$_T->get_by_id($named->{task_id})->get('want_query')
	) {
	    $named->{query} = undef;
	    next;
	}
	next
	    if exists($named->{$a})
	    || exists($named->{"carry_$a"}) && !$named->{"carry_$a"};
	$named->{$a} = $self->get($a)
    }
    return;
}

sub internal_get_named_args {
    my(undef, $names, $argv) = @_;
    # Calls name_parameters in L<Bivio::UNIVERSAL|Bivio::UNIVERSAL> then
    # converts I<task_id> to a L<$_TI|$_TI>.
    my($self, $named) = shift->name_parameters(@_);
    $named->{task_id} = !$named->{task_id} ? $self->get('task_id')
	: UNIVERSAL::isa($named->{task_id}, 'Bivio::Agent::TaskId')
	? $named->{task_id}
	: $_TI->from_name($named->{task_id})
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
    return $realm
	if $task_id->equals($self->get('task_id'));
    my($task) = $_T->get_by_id($task_id);
    return $realm
	if $task->has_realm_type($realm->get('type'));
    return $_REALM->get_general
	if $task->has_realm_type($_RT->GENERAL);
    $task->assert_realm_type($_RT->USER);
    return undef
	unless my $auth_user = $self->get('auth_user');
    $realm = $self->unsafe_get('auth_user_realm');
    return $realm
	if $realm;
    $realm = $_REALM->new($auth_user);
    $self->put_durable(auth_user_realm => $realm);
    return $realm;
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
	is_production => $proto->is_production,
	txn_resources => [],
	can_secure => $proto->can_secure,
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
    my($task) = $_T->get_by_id($new_task);
    if ($new_realm) {
	$task->assert_realm_type($new_realm->get('type'));
    }
    else {
	$self->internal_redirect_user_realm($task)
	    unless $new_realm = $self->internal_get_realm_for_task($new_task);
    }
    $self->set_realm($new_realm)
	if $new_realm;
    $self->put(
        task_id => $new_task,
        task => $_T->get_by_id($new_task),
    );
    return;
}

sub internal_redirect_user_realm {
    my($self, $task) = @_;
    $self->client_redirect($_TI->USER_HOME)
	unless $task->has_realm_type($_RT->USER);
    $self->server_redirect($_TI->LOGIN);
    # DOES NOT RETURN
}

sub internal_server_redirect {
    my($self, $named) = shift->internal_get_named_args(
    # Sets all values and saves form context.  See L<format_uri|"format_uri"> for the
    # arguments.
	[qw(task_id realm query form path_info no_context require_context no_form uri carry_query carry_path_info)],
	\@_);
    $_FCT->assert_defined_for_facade($named->{task_id}, $self);
    my($fc) = $_FM->get_context_from_request($named, $self);
    $self->internal_redirect_realm($named->{task_id}, $named->{realm});
    $named->{path_info} = undef
	unless exists($named->{path_info}) || exists($named->{carry_path_info});
    $self->internal_copy_implicit($named);
    $named->{query} = $_Q->format($named->{query})
	if ref($named->{query});
    $named->{query} = defined($named->{query})
	? $_Q->parse($named->{query}) : undef;
    $named->{uri} = $_FCT->has_uri($named->{task_id})
	? $self->format_uri({
	    map((exists($named->{$_}) ? ($_ => $named->{$_}) : ()),
		@{$self->FORMAT_URI_PARAMETERS}),
        }) : $self->get('uri');
    $named->{form_context} = $fc;
    $named->{form} = undef
	unless exists($named->{form});
    $self->put_durable_server_redirect_state($named);
    return $named->{task_id};
}

sub internal_set_current {
    my($self) = @_;
    # Called by subclasses when Request initialized.  Returns self.
    b_die($self, ': must be reference')
	unless ref($self);
    Bivio::IO::Alert->warn('replacing request:', $self->get_current)
        if $self->get_current;
    return $_CURRENT = $self;
}

sub is_http_method {
    my($self, $method) = @_;
    return $method =~ /^get$/i ? 1 : 0
	unless my $r = $self->unsafe_get('r');
    return $r->method =~ /^\Q$method\E$/i;
}

sub is_production {
    my($self) = @_;
    return ref($self)
	? $self->get_if_exists_else_put(is_production => $_CFG->{is_production})
	: $_CFG->{is_production};
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
	? _get_role($self, $_RT->GENERAL->as_int)
	    ->equals_by_name('ADMINISTRATOR')
	: Bivio::Biz::Model->new($self, 'RealmUser')->unauth_load({
	    realm_id => $_RT->GENERAL->as_int,
	    user_id => $user_id,
	    role => $_ROLE->ADMINISTRATOR,
	});
}

sub is_test {
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
        if ($_D->catch(
            sub {
                $cleaner->($self, $die);
            })
        ) {
            $is_ok = 0;
        }
    }
    $is_ok
        ? $_T->commit($self)
        : $_T->rollback($self);
    return;
}

sub push_txn_resource {
    my($self, $resource) = @_;
    # Adds a new transaction resource to this request.  I<resource> must
    # support C<handle_commit> and C<handle_rollback>.
    _trace($resource) if $_TRACE;
    my($tr) = $self->get('txn_resources');
    push(@$tr, $resource)
	unless grep($_ eq $resource, @$tr);
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
	# Allow caller to clear these values
	map((exists($named->{$_}) ? ($_ => $named->{$_}) : ()),
	    qw(query form form_model path_info)),
	# You need a uri so "undefined" means "carry"
	map((defined($named->{$_}) ? ($_ => $named->{$_}) : ()),
	    qw(uri)),
	form_context => $self->get_form_context_from_named($named),
    );
    return;
}

sub redirect {
    my($self, $args) = @_;
    my($method) = delete($args->{method}) || '';
    $self->throw_die(DIE => {
	message => 'missing or invalid method',
	entity => {%$args, method => $method},
    }) unless $method =~ /^(?:server_redirect|client_redirect)$/;
    return $self->$method($args);
}

sub server_redirect {
    my($task) = shift->internal_server_redirect(@_);
    # Server_redirect the current task to the new task.
    #
    # See L<format_uri|"format_uri"> for args.
    #
    # B<DOES NOT RETURN.>
    # clear db time
    $_C->get_db_time;
    $_D->throw_quietly(
	$_DC->SERVER_REDIRECT_TASK,
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
	? $_REALM->new($new_realm, $self)
	: $_REALM->get_general
	unless Bivio::Auth::Realm->is_blessed($new_realm);
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
    b_die($user, ': not a RealmOwner')
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

    $_D->throw($code, $attrs, $package, $file, $line);
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
    # uri,q uery, form).
    return Bivio::IO::Alert->warn(@_, ' ', $self)
}

sub with_realm {
    # Calls set_realm(realm) and then op.   Restores prior realm, even on exception.
    # Returns what I<op> returns (in array context always).
    return _with(realm => @_);
}

sub with_realm_and_user {
    my($self, $realm, $user, $op) = @_;
    return $self->with_realm($realm, sub {$self->with_user($user, $op)});
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
        next unless my $t = $form_model->get_field_type($field);
	next unless $t->can('is_secure_data') && $t->is_secure_data;
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
    return [$_ROLE->ANONYMOUS] unless $auth_user;

    # Not the current realm, but an authenticated realm
    return $user_realms->{$realm_id}->{roles}
        if ref($user_realms->{$realm_id});

    # User has no special privileges in realm
    return [$_ROLE->USER];
}

sub _with {
    my($which, $self, $with_value, $op) = @_;
    my($prev) = $self->get("auth_$which");
    my($set) = "set_$which";
    my($res);
    my($die) = $_D->catch(sub {
        $self->$set($with_value);
	$res = [$op->()];
	return;
    });
    $self->$set($prev);
    $die->throw
	if $die;
    return $self->return_scalar_or_array(@$res);
}

1;
