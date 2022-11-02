# Copyright (c) 1999-2012 bivio Software, Inc.  All rights reserved
# $Id$
package Bivio::Agent::Request;
use strict;
use Bivio::Base 'Collection.Attributes';

# C<Agent.Request> Request provides a common interface for http,...
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
# L<Biz.Model::FilePathList|Biz.Model::FilePathList>.
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
# auth_realm : Auth.Realm
#
# The realm in which the request operates.
#
# auth_role : Auth.Role
#
# Role I<auth_user> is allowed to play in I<auth_realm>.
# Set by L<Agent.Dispatcher|Agent.Dispatcher>.
#
# auth_user : Biz.Model::RealmOwner
#
# The user authenticated with the request.
#
# auth_user_id : string
#
# The user id authenticated with the request.  Set before I<auth_user>
# as a part of cookie processing.
#
# Type.UserAgent : Type.UserAgent
#
# The type of the user agent for this request.
#
# client_addr : string
#
# Client's network address if available.
#
# cookie : Agent.Cookie
#
# This is the cookie that came in the HTTP header.  It may be
# C<undef> only if the protocol doesn't support cookies.
# Very few tasks should access the cookie directly.
# If at all possible, the hidden form fields and the query string should
# be used to maintain state.
#
# Any fields set in the request cookie will be set in the reply,
# i.e. there is only one cookie for request/reply.
# See L<Agent.HTTP::Cookie|Agent.HTTP::Cookie>
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
# reply : Agent.Reply
#
# L<Agent.Reply|Agent.Reply> for this request.
#
# request : Agent.Request
#
# Always C<$self>.  Convenient for L<get_widget_value|"get_widget_value">.
#
# start_time : array_ref
#
# The time the request started as an array of seconds and microseconds.
# See L<Type.DateTime->gettimeofday|Util/"gettimeofday">.
#
# target_realm_owner : Bivio.Biz::Model::RealmOwner
#
# Set by L<Biz.Action::TargetRealm|Biz.Action::TargetRealm>.
# Used to allow a different realm to be operated on within the current
# realm.  Allows shareable code for AddressForm and such.
#
# You can use I<target_realm_owner> as an "authenticated" value, because
# C<TargetRealm> checks permissions properly.  Don't use "this" as
# an authenticated value.  See
# L<UI.HTML::Club::UserDetail|UI.HTML::Club::UserDetail>
# for an example when it loads C<TaxId>.
#
# task : Agent.Task
#
# Tuple containing the Action and View to be executed.
# Set by L<Agent.Dispatcher|Agent.Dispatcher>.
#
# task_id : Agent.TaskId
#
# Same as I<task>'s I<id>.
#
# timezone : int
#
# The user's timezone (if available).  The timezone is an offsite in
# minutes from GMT.  See use in
# L<Type.DateTime|Type.DateTime>.
#
# txn_resources : array_ref
#
# The list of resources (objects) which have transaction handlers
# (handle_commit and handle_rollback).  The handlers are called before
# any commit or rollback.
#
# Handlers are called and cleared by L<Agent.Task|Agent.Task>.
#
# user_state : Type.UserState
#
# Is the user just a visitor, logged in, or out?  Set by LoginForm.
#
# uri : string
#
# URI from the incoming request unmodified.  It is already "escaped".
#
# E<lt>ModuleE<gt> : UNIVERSAL
#
# Maps I<E<lt>ModuleE<gt>> to an instance of that modules.  Facade, Actions
# and Views will put instances as they are initialized on to the request.
# If there is an owner to the I<auth_realm>, this will be the first
# L<Bivio.Biz::Model|Biz.Model> added to the request.

# We don't import any UI components here, because they are
# initialized by Bivio::Agent::Dispatcher
our($_TRACE);
b_use('IO.Trace');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_R) = b_use('Biz.Registrar');
my($_HANDLERS) = $_R->new;
my($_A) = b_use('IO.Alert');
my($_D) = b_use('Bivio.Die');
my($_DC) = b_use('Bivio.DieCode');
my($_DT) = b_use('Type.DateTime');
my($_HTML) = b_use('Bivio.HTML');
my($_ADMINISTRATOR) = b_use('Auth.Role')->ADMINISTRATOR;
my($_ROLE_USER) = b_use('Auth.Role')->USER;
my($_ANONYMOUS) = b_use('Auth.Role')->ANONYMOUS;
my($_GENERAL) = b_use('Auth.RealmType')->GENERAL;
my($_USER) = b_use('Auth.RealmType')->USER;
my($_TI) = b_use('Agent.TaskId');
my($_T) = b_use('Agent.Task');
my($_UA) = b_use('Type.UserAgent');
my($_C) = b_use('IO.Config');
my($_E) = b_use('Type.Email');
my($_M) = b_use('Biz.Model');
my($_V1) = $_C->if_version(1);
my($_V7) = $_C->if_version(7);
$_C->register(my $_CFG = {
    can_secure => 1,
});
my($_CURRENT);
my($_JSON_ATTR) = 'req_is_json';

sub CLIENT_REDIRECT_PARAMETERS {
    # Order and names of params passed to client_redirect().
    return [
        qw(task_id realm query),
        shift->EXTRA_URI_PARAM_LIST,
        'path_info',
    ];
}

sub CLIENT_REDIRECT_PARAMETERS_WITHOUT_TASK_ID {
    return [
        qw(uri query no_context task_id realm path_info),
        shift->EXTRA_URI_PARAM_LIST,
    ];
}

sub EXTRA_URI_PARAM_LIST {
    # Only useful to this class and subclasses.  Use FORMAT_URI_PARAMETERS
    return qw(
        no_context anchor require_context
        uri form_in_query require_absolute no_form
        carry_query carry_path_info _server_redirect
        seo_uri_prefix facade_uri acknowledgement
        http_status_code require_secure
    );
}

sub FORMAT_URI_PARAMETERS {
    # Order and names of params passed to format_uri().
    return [
        qw(task_id query realm path_info),
        shift->EXTRA_URI_PARAM_LIST,
    ];
}

sub FORM_IN_QUERY_FLAG {
    return 'form_post';
}

sub REQUIRE_ABSOLUTE_GLOBAL {
    return 'format_uri.require_absolute';
}

sub SERVER_REDIRECT_PARAMETERS {
    # Order and names of params passed to server_redirect().
    return [
        qw(task_id realm query form),
        shift->EXTRA_URI_PARAM_LIST,
        'path_info',
    ];
}

sub agent_execution_is_secure {
    return shift->get('is_secure');
}

sub as_string {
    my($self) = @_;
    # Returns the important request context as a string.  Items currently
    # returned: task, user, referer, uri, query, and form.
    my($r) = $self->unsafe_get('r');
    my($t) = $self->unsafe_get('task_id');
    return $_A->format_args(
        'Request[',
        'task=',
        $t ? $t->get_name : undef,
        ' user=',
        $self->unsafe_get_nested(qw(auth_user name))
            || $r && $r->connection->user,
        ' realm=',
        ($self->unsafe_get_nested(qw(auth_realm owner_name))
             || ($self->unsafe_get('auth_realm')
             ? $self->get_nested(qw(auth_realm type))->get_name
             : undef),
        ),
        ' referer=',
        $self->unsafe_get('referer'),
        ' uri=',
        $self->unsafe_get('uri'),
        ' query=',
        $self->unsafe_get('query'),
        ' form=',
        _form_for_warning($self),
        ']',
    );
}

sub assert_http_method {
    my($self, $method) = @_;
    $self->throw_die(INVALID_OP => {
        message => "must be $method",
    }) unless $self->is_http_method($method);
    return $self;
}

sub assert_test {
    $_C->assert_test;
    return shift;
}

sub cache_for_auth_user {
    return _realm_cache('auth_user_id', @_);
}

sub cache_for_auth_realm {
    return _realm_cache('auth_id', @_);
}

sub call_process_cleanup {
    my($self, $die) = @_;
    $self->get_and_delete('process_cleanup')
        ->call_fifo(
            'handle_process_cleanup',
            [$self, $die],
            sub {
                my($op) = @_;
                my($die2) = $_D->catch(sub {$op->()});
                b_warn($die2, ': process_cleanup handler error')
                    if $die2;
                my($method) = $die2 ? 'rollback' : 'commit';
                $_T->$method($self);
                return;
            },
        );
    _init_process_cleanup($self);
    _perf_time_info($self)
        if $_TRACE;
    return;
}

sub can_user_execute_task {
    my($self, $task, $realm) = @_;
    $task = $_T->get_by_id($_TI->from_any($task))
        unless $_T->is_blesser_of($task);
    my($tid) = $task->get('id');
    return 0
        if $_V7
        && !b_use('FacadeComponent.Task')->is_defined_for_facade($tid->get_name, $self);
    if ($realm) {
        $realm = b_use('Auth.Realm')->new($realm, $self);
        $task->assert_realm_type($realm->get('type'));
    }
    else {
        $realm = $self->internal_get_realm_for_task($tid, 1);
    }
    return $realm
        ? $realm->can_user_execute_task($task, $self)
        : 0;
}

sub clear_cache_for_auth_realm {
    my($self) = @_;
    _clear_realm_cache($self, $self->get('auth_id'));
    return;
}

sub clear_cache_for_auth_user {
    my($self) = @_;
    my($u) = $self->get('auth_user');
    _clear_realm_cache($self, $u->get('realm_id'));
    return $self->set_user($u);
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
    # Clears out models (Biz.*) and any other nondurable state.  This
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
    my($self, $named) = shift->internal_client_redirect_args(@_);
    if ($named->{uri}) {
        b_die($named->{uri}, ': cannot redirect to an http URI')
            if $named->{uri} =~ /^\w+:/;
        $named->{uri} =~ s/\?(.*)//;
        $named->{query} = b_use('AgentHTTP.Query')->parse($1);
        my($task_id, $auth_realm, $path_info)
            = b_use('FacadeComponent.Task')->parse_uri($named->{uri}, $self);
        $named->{task_id} = $task_id;
        $named->{realm} = $auth_realm->unsafe_get('owner_name');
        $named->{path_info} = $path_info;
        delete($named->{uri});
    }
    return $self->server_redirect($named);
}

sub clone_return_is_self {
    return 1;
}

sub delete_from_query {
    my($self, $key) = @_;
    return undef
        unless my $q = $self->unsafe_get('query');
    my($res) = delete($q->{$key});
    $self->put(query => undef)
        unless %$q;
    return $res;
}

sub delete_txn_resource {
    my($self, $resource) = @_;
    # use new array in case something is iterating the original
    $self->put(txn_resources => [grep($_ ne $resource, @{$self->get('txn_resources')})]);
    return;
}

sub format_email {
    my($self, $email) = @_;
    # Formats the email address for inclusion in a mail header.
    # If the host is missing, adds I<Text.mail_host>.
#TODO: Properly quote the email name???
    # Will bomb if no auth_realm.
    return $self->get('auth_realm')->format_email
        unless defined($email);
    return $_E->format_email($email, undef, undef, undef, $self);
}

sub format_http {
    my($self, $named) = _uri_args('FORMAT_URI_PARAMETERS', @_);
    $named->{require_absolute} = 1;
    return $self->format_uri($named);
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
    return $self->format_uri({
        query => undef,
        realm => undef,
        path_info => undef,
        carry_query => 0,
        carry_path_info => 0,
        ref($task_id) eq 'HASH' ? %$task_id : (task_id => $task_id),
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
    # I<no_context> and I<require_context> as described by FacadeComponent.Task
    my($self, $named) = _uri_args('FORMAT_URI_PARAMETERS', @_);
    my($uri);
    b_die($named, ': must supply query with form_in_query')
        if $named->{form_in_query} && ref($named->{query}) ne 'HASH';
    my($require_secure) = $named->{require_secure};
    my($want_insecure);
    if (defined($uri = $named->{uri})) {
        $named->{no_context} = 1
            unless defined($named->{no_context})
            || defined($named->{require_context});
        $named->{uri} = $uri;
        $self->internal_copy_implicit($named);
    }
    else {
        $named->{task_id} = $self->unsafe_get('task_id')
            unless exists($named->{task_id});
        $self->internal_copy_implicit($named);
        $named->{realm} = $self->internal_get_realm_for_task($named->{task_id})
            unless defined($named->{realm});
        $require_secure        ||= _need_to_secure_task($self, $named->{task_id});
        $want_insecure ||= _need_to_make_task_insecure($self, $named->{task_id});
        $named->{no_form} = 0
            if $require_secure || $want_insecure;
    }
    $self->internal_call_handlers(handle_format_uri_named => [$named, $self]);
    $uri = b_use('FacadeComponent.Task')->format_uri($named, $self);
    if (defined($named->{query})) {
        $named->{query}->{$self->FORM_IN_QUERY_FLAG} = 1
            if $named->{form_in_query};
        $named->{query} = b_use('AgentHTTP.Query')->format($named->{query}, $self)
            if ref($named->{query});
        $uri =~ s/\?/?$named->{query}&/ || ($uri .= '?'.$named->{query})
            if defined($named->{query}) && length($named->{query});
    }
    $uri .= '#' . $_HTML->escape_query($named->{anchor})
        if defined($named->{anchor}) && length($named->{anchor});
    return _absolute_uri($self, $uri, $require_secure, $want_insecure, $named->{facade_uri})
        if $require_secure || $want_insecure || $named->{facade_uri} || $named->{require_absolute};
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
    return undef;
}

sub get_form_context_from_named {
    my($self, $named) = @_;
    # Used to communicate between FacadeComponent.Task
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
                  : b_use('Biz.FormModel')->get_context_from_request(
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

sub if_req_is_json {
    my($self) = shift;
    return $self->if_then_else($self->unsafe_get($_JSON_ATTR), @_);
}

sub if_test {
    my($self) = shift;
    return $self->if_then_else($self->is_test, @_);
}

sub internal_call_handlers {
    shift;
    $_HANDLERS->call_fifo(@_);
    return;
}

sub internal_clear_current {
    # DO NOT CALL THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
    $_CURRENT = undef;
    return;
}

sub internal_client_redirect_args {
    my($self) = shift;
    my($first) = @_;
    my(undef, $named) = $self->internal_get_named_args(
         ref($first) && (ref($first) ne 'HASH' || $first->{task_id})
            || $_TI->is_valid_name($first)
            ? $self->CLIENT_REDIRECT_PARAMETERS
            : $self->CLIENT_REDIRECT_PARAMETERS_WITHOUT_TASK_ID,
        \@_,
    );
    if (defined($named->{uri})) {
        # NOTE: This form never had implicit query/path_info copying
        foreach my $a (qw(query path_info)) {
            $named->{$a} = undef
                unless exists($named->{$a}) || exists($named->{"carry_$a"});
        }
        $self->internal_copy_implicit($named);
        $named->{query} = b_use('AgentHTTP.Query')->format($named->{query}, $self)
            if ref($named->{query});
        $named->{uri} =~ s/\?/\?$named->{query}&/
            || ($named->{uri} .= '?'.$named->{query})
            if defined($named->{query}) && length($named->{query});
        delete($named->{query});
    }
    return ($self, $named);
}

sub internal_copy_implicit {
    my($self, $named) = @_;
#TODO: I think carry_query should override anything if it is set
    foreach my $attr (qw(query path_info)) {
        my($carry) = exists($named->{"carry_$attr"}) && $named->{"carry_$attr"};
        if (!$carry
            && $attr eq 'query'
            && $named->{task_id}
            && !$named->{uri}
            && !$_T->get_by_id($named->{task_id})->get('want_query')
        ) {
            $named->{query} = undef;
            next;
        }
        next
            if exists($named->{$attr})
             || exists($named->{"carry_$attr"}) && !$named->{"carry_$attr"};
        $named->{$attr} = $self->get($attr)
    }
    return;
}

sub internal_get_named_args {
    my(undef, $names, $argv) = @_;
    b_die($argv, ': too many positional parameters')
        if @$argv > 5;
    # Calls name_parameters in L<UNIVERSAL|Bivio.UNIVERSAL> then
    # converts I<task_id> to a L<$_TI|$_TI>.
    my($self, $named) = shift->name_parameters(@_);
#TODO: Make a Type
    $named->{task_id} = !$named->{task_id} ? $self->get('task_id')
        : $_TI->is_blesser_of($named->{task_id})
        ? $named->{task_id}
        : $_TI->from_name($named->{task_id})
        if grep($_ eq 'task_id', @$names);
    $named->{require_absolute} = 1
        if $named->{require_secure}
        || !defined($named->{require_absolute})
        && $self->unsafe_get($self->REQUIRE_ABSOLUTE_GLOBAL);
    _trace((caller(1))[3], $named) if $_TRACE;
    return ($self, $named);
}

sub internal_get_realm_for_task {
    my($self, $task_id, $no_die) = @_;
    # Returns the realm for the specified task.  If the realm type of the
    # task matches the current realm, current realm is returned.
    #
    # B<Deprecated> Otherwise, we return the best realm that matches the type of
    # the task.
    # If is current task, just return current realm.
    my($realm) = $self->get('auth_realm');
    _trace('current auth_realm is: ', $realm->get('id'))
        if $_TRACE;
    my($task) = $_T->get_by_id($task_id);
    return $realm
        if $task->has_realm_type($realm->get('type'));
    return b_use('Auth.Realm')->get_general
        if $task->has_realm_type($_GENERAL);
    unless ($task->has_realm_type($_USER)) {
        b_die($task, ': unable to determine realm type for task')
            unless $no_die;
    }
    if (my $au = $self->get('auth_user')) {
        return b_use('Auth.Realm')->new($au);
    }
    return undef;
}

sub internal_initialize {
    my($self, $auth_realm, $auth_user) = @_;
    # Called by subclass after it has initialized all state.
    $self->set_user($auth_user);
    $self->set_realm($auth_realm);
    return $self;
}

sub internal_initialize_with_uri {
    my($self, $full_uri, $query) = @_;
    my($task_id, $auth_realm, $path_info, $uri, $initial_uri)
        = b_use('FacadeComponent.Task')->parse_uri($full_uri, $self);
    $self->internal_set_current;
    $query = b_use('AgentHTTP.Query')->parse($query);
    # SECURITY: Make sure the auth_id is NEVER set by the user.
    delete($query->{auth_id})
        if $query;
    return $self->put_durable(
        uri => $uri && $_HTML->escape_uri($uri),
        initial_uri => $initial_uri,
        query => $query,
        path_info => $path_info,
        task_id => $task_id,
    )->internal_initialize($auth_realm, $self->unsafe_get('auth_user'));
}

sub internal_need_to_toggle_secure_agent_execution {
    my($self, $task) = @_;
    my($is_secure) = $self->agent_execution_is_secure;
    return !$is_secure && _need_to_secure_task($self, $task)
        || $is_secure && _need_to_make_task_insecure($self, $task);
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
    my($self) = $proto->SUPER::new;
    $self->put_durable(
        %$attributes,
        request => $self,
        is_production => $proto->is_production,
        txn_resources => [],
        start_time => $_DT->gettimeofday,
        perf_time => {},
    );
    _init_process_cleanup($self);
    # Make sure a value gets set
    $_UA->execute_unknown($self);
    _trace($self) if $_TRACE;
    return $self;
}

sub internal_redirect_realm {
    my($self, $new_task, $new_realm) = @_;
    # Changes the current realm if required by the new task.
    my($fields) = $self->[$_IDI];
    my($task) = $_T->get_by_id($new_task);
    if ($new_realm) {
        $new_realm = _load_realm($self, $new_realm);
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
        unless $task->has_realm_type($_USER);
    $self->server_redirect($_TI->LOGIN);
    # DOES NOT RETURN
}

sub internal_server_redirect {
    my($self, $named) = _uri_args('SERVER_REDIRECT_PARAMETERS', @_);
    b_use('FacadeComponent.Task')
        ->assert_defined_for_facade($named->{task_id}, $self);
    $self->internal_copy_implicit($named);
    $named->{query} = b_use('AgentHTTP.Query')->format($named->{query}, $self)
        if ref($named->{query});
    $named->{query} = defined($named->{query})
        ? b_use('AgentHTTP.Query')->parse($named->{query}) : undef;
    my($fc) = b_use('Biz.FormModel')->get_context_from_request($named, $self);
    $self->internal_redirect_realm($named->{task_id}, $named->{realm});
    $named->{path_info} = undef
        unless exists($named->{path_info}) || exists($named->{carry_path_info});
    $named->{uri} = b_use('FacadeComponent.Task')->has_uri($named->{task_id}, $self)
        ? $self->format_uri({
            map((exists($named->{$_}) ? ($_ => $named->{$_}) : ()),
                @{$self->FORMAT_URI_PARAMETERS}),
        }) : $self->get('uri');
    $named->{form_context} = $fc;
    $named->{form} = undef
        unless exists($named->{form});
    $named->{method} = 'server_redirect';
    $self->internal_call_handlers(handle_server_redirect => [$named, $self]);
    $self->put_durable_server_redirect_state($named);
    return $named->{task_id};
}

sub internal_set_current {
    my($self) = @_;
    # Called by subclasses when Request initialized.  Returns self.
    b_die($self, ': must be reference')
        unless ref($self);
    b_warn('replacing request:', $self->get_current)
        if $self->get_current;
    return $_CURRENT = $self;
}

sub is_http_content_type {
    my($self, $type) = @_;
    return _is_r_value($self, 'content_type', qr{^\Q$type\E(?:[;\s]|$)}is, '');
}

sub is_http_method {
    my($self, $method) = @_;
    return _is_r_value($self, 'method', qr{^\Q$method\E$}i, 'get');
}

sub is_production {
    my($self) = @_;
#TODO: probably should not is_production on request, but use config({}) in tests
    return ref($self)
        ? $self->get_if_exists_else_put(is_production => $_C->is_production)
        : $_C->is_production;
}

sub is_site_admin {
    my($self) = @_;
    return $self->match_user_realms({
        'RealmUser.realm_id' => b_use('FacadeComponent.Constant')
            ->get_value('site_realm_id', $self),
        roles => $_ADMINISTRATOR,
    });
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
        ? _get_role($self, $_GENERAL->as_int)
            ->equals_by_name('ADMINISTRATOR')
        : $_M->new($self, 'RealmUser')->unauth_load({
            realm_id => $_GENERAL->as_int,
            user_id => $user_id,
            role => $_ADMINISTRATOR,
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
                        == grep({
                            my($fv) = $filter->{$_};
                            grep({
                                my($xv) = $_;
                                ref($fv) eq 'ARRAY' ? grep($xv eq $_, @$fv)
                                    : $xv eq $fv;
                            } ref($x->{$_}) eq 'ARRAY' ? @{$x->{$_}} : $x->{$_})
                                ? 1 : 0;
                        } keys(%$filter));
                } values(%{$self->get('user_realms')}))))];
    return [map($op->($_), @$atomic_copy)];
}

sub match_user_realms {
    my($self) = shift;
    return @{$self->map_user_realms(sub {1}, @_)} ? 1 : 0;
}

sub need_to_toggle_secure_agent_execution {
    return shift->internal_need_to_toggle_secure_agent_execution(@_);
}

sub new {
    # B<Terminates caller.>  Use L<get_current_or_new|"get_current_or_new">.
    die('only can initialize from subclasses');
}

sub perf_time_inc {
    my($self, $pkg, $start) = @_;
    return
        unless $self = $self->unsafe_get_current_root;
    my($delta) = $_DT->gettimeofday_diff_seconds($start);
    $self->get('perf_time')->{$pkg} += $delta;
    return $delta;
}

sub perf_time_op {
    my($proto, $pkg, $op, $delta_ref) = @_;
    return $op->()
        unless $delta_ref || $_TRACE
        and my $self = ref($proto) ? $proto : $proto->get_current;
    my($start) = $_DT->gettimeofday;
    my($res) = $op->();
    my($delta) = $self->perf_time_inc($pkg, $start);
    $$delta_ref = $delta
        if $delta_ref;
    return $self->return_scalar_or_array($res);
}

sub push_process_cleanup {
    my($self, $handler) = @_;
    $self->get('process_cleanup')->push_object($handler);
    return;
}

sub push_txn_resource {
    my($self, $resource) = @_;
    # Adds a new transaction resource to this request.  I<resource> must
    # support C<handle_commit> and C<handle_rollback>.
#TODO: use Biz.Registrar
    my($tr) = $self->get('txn_resources');
    return
        if grep($_ eq $resource, @$tr);
    push(@$tr, $resource);
    _trace($resource) if $_TRACE;
    return;
}

sub put {
    my($self) = shift;
    return $self->SUPER::put(@{$self->map_by_two(
        sub {
            my($key, $value) = @_;
            if ($key =~ /^auth_(realm|user)\./s) {
                $_A->warn_deprecated($key, ': use realm_cache');
            }
            elsif ($key eq 'query') {
                $value = b_use('AgentHTTP.Query')->parse($value)
                    if defined($value) && ref($value) ne 'HASH';
            }
            return ($key, $value);
        },
        \@_,
    )});
}

sub put_durable {
    my($self) = shift;
    # Puts durable attributes on the request.  A durable attribute survives
    # redirects.
    my($durable_keys) = $self->get_if_exists_else_put(
        'durable_keys',
        {durable_keys => 1},
    );
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

sub put_req_is_json {
    return shift->put_durable($_JSON_ATTR => 1)
}

sub realm_cache {
    $_A->warn_deprecated('use cache_for_auth_realm');
    return shift->cache_for_auth_realm(@_);
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

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub server_redirect {
    my($self, $named) = _uri_args('SERVER_REDIRECT_PARAMETERS', @_);
    # Do not recurse
    b_die($named, ': recursive redirects')
        if $named->{_server_redirect}++;
    return $self->client_redirect($named)
        if $self->need_to_toggle_secure_agent_execution($named->{task_id});
    $_D->throw_quietly(
        $_DC->SERVER_REDIRECT_TASK,
        {task_id => $self->internal_server_redirect($named)},
    );
    # DOES NOT RETURN
}

sub set_current {
    return shift->internal_set_current();
}

sub set_realm {
    my($self, $new_realm) = @_;
    $new_realm = _load_realm($self, $new_realm);
    my($realm_id) = $new_realm->get('id');
    my($new_role) = _get_role($self, $realm_id);
    my($new_roles) = _get_roles($self, $realm_id);
#TODO: remove after realm_cache proven
    $self->delete_all_by_regexp(qr{^auth_realm\.});
    $self->put_durable(
        auth_realm => $new_realm,
        auth_id => $realm_id,
        auth_role => $new_role,
        auth_roles => $new_roles,
    );
    _trace($new_realm, '; ', $new_roles) if $_TRACE;
    return $new_realm;
}

sub set_realm_unless_same {
    my($self, $name_or_id) = @_;
    return
        if $self->req('auth_realm')->equals_by_name_or_id($name_or_id);
    return shift->set_realm(@_);
}

sub set_task {
    my($self, $task_id) = @_;
    $task_id = $_TI->from_name($task_id)
        unless ref($task_id);
#TODO: b_use('FacadeComponent.Task')->is_defined_for_facade($tid->get_name, $self);
    _trace($task_id) if $_TRACE;
    my($task) = $_T->get_by_id($task_id);
    $task_id->if_task_is_json(sub {$self->put_req_is_json});
    $self->put_durable(
        task_id => $task_id,
        task => $task,
    );
#TODO: This coupling needs to be explicit.  Probably with a handler.
    $self->delete(qw(list_model form_model));
    return $task;
}

sub set_task_and_uri {
    my($self, $uri_attrs) = @_;
    $self->set_task(
        $uri_attrs->{task_id} || b_die($uri_attrs, ': task_id is required'),
    );
    return
        unless b_use('FacadeComponent.Task')
        ->has_uri($self->get('task_id'), $self);
    my($uri) = $self->format_uri($uri_attrs = {
        query => undef,
        path_info => undef,
        %$uri_attrs,
        task_id => $self->get('task_id'),
    });
#TODO: This probably wants to be with_task, just need to
#      define the context to return to.
    $self->put_durable(
        map(exists($uri_attrs->{$_}) ? ($_, $uri_attrs->{$_}) : (),
            qw(query path_info)),
        uri => $uri,
        initial_uri => $uri,
    );
    return;
}

sub set_user {
    my($self, $user) = @_;
    # B<Use
    # L<Biz.Model::LoginForm|Biz.Model::LoginForm>
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
    $user = $_M->new($self, 'RealmOwner')
        ->unauth_load_by_id_or_name_or_die($user, 'USER')
        unless ref($user) || !defined($user);
    # DON'T CHECK CURRENT USER.  Always reread DB.
    my($user_realms);
    _trace($user) if $_TRACE;
    if ($user) {
        # Load the UserRealmList for this user.
        my($list) = $_M->new($self, 'UserRealmList');
        $list->unauth_load_all({auth_id => $user->get('realm_id')});
        $user_realms = $list->map_primary_key_to_rows;
    }
    else {
        $user_realms = {};
    }
    b_die($user, ': not a RealmOwner')
        if defined($user) && !$_M->is_blesser_of($user);
#TODO: remove after realm_cache proven
    $self->delete_all_by_regexp(qr{^auth_user\.});
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

sub unsafe_from_query {
    my($self) = shift;
    return
        unless my $q = $self->unsafe_get('query');
    return $self->return_scalar_or_array(map($q->{$_}, @_));
}

sub unsafe_get_current_root {
    return shift->get_current;
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
    return b_warn(@_, ' ', $self)
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

sub _clear_realm_cache {
    my($self, $realm_id) = @_;
    $self->delete_all_by_regexp(
        qr{@{[
            join(
                '#',
                'realm_cache',
                $realm_id,
                '.*',
            )
        ]}},
    );
    return;
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
        next unless $t->b_can('is_secure_data') && $t->is_secure_data;
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
    return [$_ANONYMOUS] unless $auth_user;

    # Not the current realm, but an authenticated realm
    return $user_realms->{$realm_id}->{roles}
        if ref($user_realms->{$realm_id});

    # User has no special privileges in realm
    return [$_ROLE_USER];
}

sub _absolute_uri {
    my($self, $uri, $require_secure, $want_insecure, $facade_uri) = @_;
    my($facade) = $facade_uri ? b_use('UI.Facade')->get_instance($facade_uri)
        : b_use('UI.Facade')->get_from_source($self);
    my($host, $rel_uri) = _absolute_uri_validate($self, $uri, $facade_uri, $facade);
    return $uri
        unless $rel_uri;
    return _absolute_uri_http($self, $require_secure, $want_insecure, $facade)
        . '://'
        . $host
        . $rel_uri;
}

sub _absolute_uri_http {
    my($self, $require_secure, $want_insecure, $facade) = @_;
    return $_CFG->{can_secure}
        && !$want_insecure
        && (
            $require_secure
            || $self->unsafe_get('is_secure')
            || $facade->get('Constant')->get_value('require_secure')
        ) ? 'https' : 'http';
}

sub _absolute_uri_validate {
    my($self, $uri, $facade_uri, $facade) = @_;
    my($host);
    if ($uri =~ s/^https?://) {
        b_die($uri, ': invalid http uri passed to format_uri')
            unless $uri =~ s{^//([^/]+)}{};
        $host = $1;
    }
    elsif ($uri =~ /^\w+:/) {
#TODO: Verify this doesn't happen in the logs
        b_warn($uri, ': format_uri passed a non-http uri');
        return;
    }
    return (
        _absolute_uri_validate_host($self, $host, $facade_uri, $facade),
        $uri || '/',
    );
}

sub _absolute_uri_validate_host {
    my($self, $host, $facade_uri, $facade) = @_;
    return $facade->get('http_host')
        unless $host;
    unless (b_use('UI.Facade')->find_by_uri_or_domain($host =~ /^([^:]+)/)) {
        b_warn($host, ': host does not match any facade');
    }
    if ($facade_uri && $host && $host ne $facade->get('http_host')) {
        b_warn($facade_uri, ': facade_uri does not equal host=', $host);
    }
    return $host;
}

sub _init_process_cleanup {
    my($self) = @_;
    my($process_cleanup) = $self->unsafe_get_and_delete('process_cleanup');
    $self->put_durable(process_cleanup => $_R->new);
    $self->push_process_cleanup($process_cleanup)
        if $process_cleanup;
    return;
}

sub _is_r_value {
    my($self, $which, $expect, $default) = @_;
    return $default =~ $expect ? 1 : 0
        unless my $r = $self->unsafe_get('r');
    return $r->$which =~ $expect ? 1 : 0;
}

sub _load_realm {
    my($self, $new_realm) = @_;
    return b_use('Auth.Realm')->is_blesser_of($new_realm) ? $new_realm
        : defined($new_realm)
        ? b_use('Auth.Realm')->new($new_realm, $self)
        : b_use('Auth.Realm')->get_general
}

sub _need_to_make_task_insecure {
    my($self, $task) = @_;
    $task = $_T->get_by_id($task)
        unless $_T->is_blesser_of($task);
    return $_CFG->{can_secure}
        && $task->unsafe_get('want_insecure')
        && $self->unsafe_get('is_secure');
}

sub _need_to_secure_task {
    my($self, $task) = @_;
    $task = $_T->get_by_id($task)
        unless $_T->is_blesser_of($task);
    return $_CFG->{can_secure}
        && !$task->unsafe_get('want_insecure')
        && !$self->unsafe_get('is_secure')
        && ($task->get('require_secure')
            || b_use('FacadeComponent.Constant')
                ->get_value('require_secure', $self)
        );
}

sub _perf_time_info {
    my($self) = @_;
    my($start) = $self->get('start_time');
    $self->perf_time_inc(__PACKAGE__, $start);
    my($pt) = $self->get('perf_time');
    b_info([map(
        sprintf(
            '%s=%.3f',
            $_->simple_package_name,
            $pt->{$_},
        ),
        sort(keys(%$pt)),
    )]);
    $self->put(start_time => $_DT->gettimeofday);
    %$pt = ();
    return;
}

sub _realm_cache {
    my($which, $self, $key, $compute) = @_;
    # Key includes caller's package and line for uniqueness
    return $self->get_if_exists_else_put(
        join(
            '#',
            'realm_cache',
            $self->get($which) || 0,
            (caller(1))[0,2],
            ref($key) ? @$key : $key,
        ),
        $compute,
    );
    return;
}

sub _uri_args {
    my($decl, $self) = (shift, shift);
    return $self->internal_get_named_args($self->$decl, \@_);
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
