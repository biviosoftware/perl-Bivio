# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Task;
use strict;
$Bivio::UI::Task::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Task::VERSION;

=head1 NAME

Bivio::UI::Task - provides URIs for tasks
n
=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Task;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::Task::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::Task> provides URIs for tasks.  There are two uris currently
provided: L<format_uri|"format_uri"> and L<format_help_uri|"format_help_uri">.

Tasks are configured as follows:

     group(<TASK_NAME> => <uri>);
     group(<TASK_NAME> => {
         uri => <uri>,
         help => <help-path-info>,
     });
     group(<TASK_NAME> => {
         uri => [<primary-uri>, <alias1>, <alias2>, ...],
         help => <help-path-info>,
     });

The first case is simply a shorthand for the second without a I<help>
attribute.

The I<uri> is a relative path to the task which starts at the root of the site
(/).  The I<uri> may be a list in which case the first URI is the one returned
by L<format_uri|"format_uri">.

Choose your I<uri>s carefully.  We recommend using dash/minus (-) to separate
values within the same uri component, e.g. my-component vs. my_component.
Dashes are readable when underlined and they are legal URI characters.

A I<uri> may contain a realm name (see special characters below).  We restrict
vvthis to the top level name in the space.  This is an efficiency concern, but it
is also pragmatic.  It enforces a practical naming convention which allows you
to avoid collisions between reserved realm names (see
L<Bivio::Type::RealmName|Bivio::Type::RealmName>) and URI components.  Indeed
we give these URIs a special name: I<realm owner relative> (ROR).

I<uri> may contain special characters as follows:

=over 4

=item ?

Question mark (?) identifies a I<realm owner relative> (ROR) uri.  The URI
operates in a security realm (CLUB, USER, etc.).  The question mark (?) is a
placeholder for a realm owner name, e.g.  ?/accounting would map to
my_club/accounting if my_club were the current realm owner name.  It may appear
as the first component of the path only, e.g. C<?/edit/address> but not
C<edit/?/address>.  During rendering, the value will be filled in with the
passed in realm name or the I<auth_realm> on the request.

=item *

May appear as the trailing component of the URI, e.g. /help/*.  We restrict
path info to the second component in ownerless URIs (no question marks) and the
third component in ROR uris.  An incoming URI will be parsed and the
I<path_info> will be placed on the request.  An outgoing URI will have
I<path_info> appended (see L<format_uri|"format_uri">).

=back

=head1 REQUIRED TASKS

=over 4

=item HELP

The task which L<format_help_uri|"format_help_uri"> uses to format uris.
This task must have a I<help> attribute which is where help is routed
to.

=item SITE_ROOT

The I<uri> of this task must be C</*>, i.e. the root of all URIs.
This task will be executed.

=back

=cut

=head1 CONSTANTS

=cut

=for html <a name="HELP_INDEX"></a>

=head2 HELP_INDEX : string

Index for help tree.

=cut

sub HELP_INDEX {
    return '/index.html';
}

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG : hash_ref

Returns a hash with a special key.

=cut

sub UNDEF_CONFIG {
    return {
	undef_config => 1,
    };
}

=for html <a name="UNDEF_URI"></a>

=head2 UNDEF_URI : string

URI to use when task is not found or error converting to URI.

=cut

sub UNDEF_URI {
    return 'TASK-ERR';
}

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::General;
use Bivio::Auth::RealmType;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::HTML;
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_GENERAL) = Bivio::Auth::Realm::General->new;
my($_GENERAL_INT) = Bivio::Auth::RealmType->GENERAL->as_int;
my($_SITE_ROOT) = Bivio::Agent::TaskId->SITE_ROOT;
my($_REALM_PLACEHOLDER) = '?';
my($_REALM_PLACEHOLDER_PAT) = $_REALM_PLACEHOLDER;
$_REALM_PLACEHOLDER_PAT =~ s/(\W)/\\$1/g;
# Map of realm types to default realm placeholders

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Task

Returns a new Task instance.

=cut

sub new {
    return Bivio::UI::FacadeComponent::new(@_);
}

=head1 METHODS

=cut

=for html <a name="assert_defined_for_facade"></a>

=head2 assert_defined_for_facade(Bivio::Agent::TaskId task, Bivio::Collection::Attributes req_or_facade)

Dies if task is not defined for this facade.

=cut

sub assert_defined_for_facade {
    my($proto, $task, $req_or_facade) = @_;
    my($v) = $proto->internal_get_value(lc($task->get_name), $req_or_facade);
    Bivio::Die->throw_die('NOT_FOUND', {
	entity => $task,
	message => 'no such task in facade',
    }) unless $v->{is_valid};
    return;
}

=for html <a name="format_help_uri"></a>

=head2 format_help_uri(Bivio::Agent::TaskId task, Bivio::Agent::Request req) : string

=head2 format_help_uri(string task, Bivio::Agent::Request req) : string

Formats the help uri for this task.  If the task doesn't have a specific help,
returns the root of the help tree.

If I<task> is C<undef>, returns the root uri of the help tree.

=cut

sub format_help_uri {
    my($proto, $task, $req) = @_;
    my($self) = $proto->internal_get_self($req);
    my($info) = $task
	    ? $self->internal_get_value(ref($task) ? $task->get_name  : $task)
	    : undef;
    return $self->format_uri(
#TODO: Allow HELP per realm_type
	    Bivio::Agent::TaskId->HELP,
	    undef,
	    $info && $info->{help} ? $info->{help}
	    : Bivio::UI::Text->get_value('help_index_path_info'),
	    0,
	    $req,
	   );
}

=for html <a name="format_realmless_uri"></a>

=head2 static format_realmless_uri(Bivio::Agent::TaskId task_id, string path_info, Bivio::Agent::Request req) : string

Formats a stateless, realmless URI.  It uses my-club-site or
my-site for the realm in the URI.

B<This is an experimental method.>

=cut

sub format_realmless_uri {
    my($proto, $task_id, $path_info, $req) = @_;
    my($self) = $proto->internal_get_self($req);
    my($fields) = $self->{$_PACKAGE};
    return $proto->format_uri(
	    $task_id,
	    $fields->{realmless_uri}->{
		Bivio::Agent::Task->get_by_id($task_id)->get('realm_type')
	    },
	    $path_info,
	    1,
	    $req);
}

=for html <a name="format_uri"></a>

=head2 static format_uri(Bivio::Agent::TaskId task_id, Bivio::Auth::Realm realm, string path_info, boolean no_context, Bivio::Agent::Request req) : string

=head2 static format_uri(Bivio::Agent::TaskId task_id, string realm_name, string path_info, boolean no_context, Bivio::Agent::Request req) : string

Transforms I<task_id> and I<realm> (if needed) into a URI.
I<realm_name> must be a legitimate realm name.

B<path_info is not escaped.>

=cut

sub format_uri {
    my($proto, $task_id, $realm, $path_info, $no_context, $req) = @_;
    my($self) = $proto->internal_get_self($req);
    my($task_name) = $task_id->get_name;
    my($info) = $self->internal_get_value($task_name);
    return _get_error($self, $task_name) unless defined($info->{uri});
    my($uri) = $info->{uri};

#TODO: Add in the form context with \& at the end which turns into nothing
# if no context added.
    # URI contains a question mark
    if ($uri =~ /$_REALM_PLACEHOLDER_PAT/o) {
	return _get_error($self, $task_name,
		'uri requires but realm not defined')
			unless defined($realm);
	my($ro);
	if (ref($realm)) {
	    # If the realm doesn't have an owner, there's a bug somewhere
	    $ro = $realm->get('owner_name');
	}
	else {
	    # We're a little strict here, since we added this overload later
	    return _get_error($self, $task_name, $realm,
		    'not a simple realm name or placeholder')
		    # The '-' is for my-club-site, not for realm names
		    unless $realm =~ /^[-\w]+$/;
	    $ro = $realm;
	}
	# Replace everything leading up to placeholder with the uri prefix
	$uri =~ s/.*$_REALM_PLACEHOLDER_PAT/\/$ro/og;
    }
    $uri = '/'.$uri unless $uri =~ /^\//;

    # Append path_info, if necessary.  Note that we don't check for
    # "defined", because path_info is returned as '' from "parse".
    # We do this so we can handle safely in various bits of code.
    # path_info must begin with a '/' if it is set.
    if ($info->{has_path_info}) {
	if ($path_info) {
	    return _get_error($self, $task_name, 'uri requires path_info')
			    unless $path_info;
	    return _get_error($self, $task_name,
		    'path_info must begin with slash (', $path_info, ')')
			unless $path_info =~ /^\//;
	    # Deletes trailing '/' on URI (only happens in case of DOC ROOT)
	    $uri =~ s/\/$//;
	    $uri .= Bivio::HTML->escape_uri($path_info);
	}
    }
    else {
#TODO: This assertion check doesn't work
#	Bivio::Die->die($task_id, '(', $uri,
#		'): does not require path_info (', $path_info, ')')
#		    if $path_info;
    }

    # This prevents recursion with FormModel callbacks.  Also used
    # in where context is counter-productive.
    return $uri if $no_context;

    # Tightly coupled with UI::HTML::Widget::Form.
    my($rc) = Bivio::Agent::Task->get_by_id($task_id)->get('require_context');
    $uri .= Bivio::Biz::FormModel->format_context_as_query($req, $task_id)
	    if $rc;
    return $uri;
}

=for html <a name="handle_register"></a>

=head2 static handle_register()

Registers with Facade.

=cut

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto, ['Text']);
    return;
}

=for html <a name="has_help"></a>

=head2 has_help(Bivio::Agent::TaskId task_id, Bivio::Collection::Attributes req_or_facade) : boolean

=head2 has_help(string task_id, Bivio::Collection::Attributes req_or_facade) : boolean

Does the task have a help topic?

=cut

sub has_help {
    my($proto, $task_id, $req_or_facade) = @_;
    return defined($proto->internal_get_value(
	    ref($task_id) ? $task_id->get_name : $task_id, $req_or_facade)
	    ->{help}
	   ) ? 1 : 0;
}

=for html <a name="has_uri"></a>

=head2 has_uri(Bivio::Agent::TaskId task_id, Bivio::Collection::Attributes req_or_facade) : boolean

=head2 has_uri(string task_id, Bivio::Collection::Attributes req_or_facade) : boolean

Does the task have a uri?

=cut

sub has_uri {
    my($proto, $task_id, $req_or_facade) = @_;
    return defined($proto->internal_get_value(
	    ref($task_id) ? $task_id->get_name : $task_id, $req_or_facade)
	    ->{uri}
	   ) ? 1 : 0;
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Generates internal tables.

=cut

sub initialization_complete {
    my($self) = @_;
    my($fields) = _initialize_fields($self);
    delete($fields->{to_realm_type});

    _init_basic($self);
    _init_from_uri($self, $self->internal_get_all_groups);

    # Map default placeholders for these realms.  See format_realmless_uri().
    $fields->{realmless_uri} = {
	# You can't format realmless unless these tasks exist.
#TODO: make my_club_site and my_site configurable
	Bivio::Auth::RealmType::CLUB()
		=> $self->internal_get_value('my_club_site')->{uri},
	Bivio::Auth::RealmType::USER()
	        => $self->internal_get_value('my_site')->{uri},
	Bivio::Auth::RealmType::GENERAL() => undef,
    };

    $self->SUPER::initialization_complete();
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

Sets up the attributes for this value.  There can be no grouped values, so we
check to make sure I<names> is a single value.  C<undef> causes
L<UNDEF_URI|"UNDEF_URI"> to be mapped.  We set I<from_uri>
and I<placeholder> here.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;
    my($fields) = _initialize_fields($self);

    # Special case undefined value
    return _init_err($self, $value)
	    if ref($value->{config}) eq 'HASH'
		    && $value->{config}->{undef_config};

    foreach my $s (\&_init_config, \&_init_name, \&_init_uri) {
	my($err) = &$s($fields, $value);
	return _init_err($self, $value, $err) if $err;
    }
    $value->{is_valid} = 1;
    return;
}

=for html <a name="is_defined_for_facade"></a>

=head2 is_defined_for_facade(Bivio::Agent::TaskId task, Bivio::Collection::Attributes req_or_facade) : boolean

Returns true if I<task> is defined in this facade.

=cut

sub is_defined_for_facade {
    my($proto, $task, $req_or_facade) = @_;
    return $proto->internal_get_value(lc($task->get_name), $req_or_facade)
	    ? 1 : 0;
}

=for html <a name="parse_uri"></a>

=head2 static parse_uri(string uri, Bivio::Agent::Request req) : array

Returns I<task_id>, I<auth_realm>, I<path_info>, and new I<uri> for I<uri>.

Note that the I<path_info> is left on the URI.

=cut

sub parse_uri {
    my($proto, $uri, $req) = @_;

    # We don't set the facade if the request already has one,
    # because parse_uri is currently called from more than one place
    # during the request.
    my($facade) = $uri =~ s/^\/*\*(\w+)// ? $1 : undef;
    $facade = $req->unsafe_get('facade')
	    || Bivio::UI::Facade->setup_request($facade, $req);
    my($self) = $facade->get('Task');
    my($fields) = $self->{$_PACKAGE};

    my($orig_uri) = $uri;
    $uri =~ s!^/+!!;

    # Special case: '/' or ''
    unless (length($uri)) {
	_trace($orig_uri,  '=> special case root') if $_TRACE;
	$req->put_durable(initial_uri => '/');
	return ($_SITE_ROOT, $_GENERAL, '', '/');
    }

    # Question mark is a special character
    my(@uri) = map {
	$req->throw_die(Bivio::DieCode::NOT_FOUND,
		{entity => $orig_uri, message => 'contains special char'})
		if $_ eq $_REALM_PLACEHOLDER;
	$_;
    } split(/\/+/, $uri);

    # There is always something in $uri and @uri at this point
    $uri = join('/', @uri);
    my($info);
    $req->put_durable(initial_uri => '/'.$uri);

    # General realm simple map; no placeholders or path_info.
    if (defined($info = $fields->{from_uri}->{$uri}->[$_GENERAL_INT])) {
	_trace($orig_uri, ' => ', $info->{task}) if $_TRACE;
	return ($info->{task}, $_GENERAL, '', $orig_uri);
    }

    # Is this a general realm with path_info?  URI has at least
    # one component at this stage, so $uri[0] is defined.
    if (defined($info = $fields->{from_uri}->{$uri[0]}->[$_GENERAL_INT])) {
	# At this stage, we have to map to a general realm, because
	# all first components of the general realm are not valid
	# Bivio::Type::RealmName values.  Therefore, we fail with
	# not found if it matches the first component, but the task
	# doesn't have path_info.
	if ($info->{has_path_info}) {
	    _trace($orig_uri, ' => ', $info->{task}) if $_TRACE;
	    return ($info->{task}, $_GENERAL, '/'.join('/', @uri[1..$#uri]),
		    $orig_uri);
	}

	# The URI doesn't accept path_info, so not found.
	$req->throw_die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
	    orig_uri => $orig_uri,
	    uri => $uri,
	    message => 'no such general URI (not a path_info uri)'});
	# DOES NOT RETURN
    }

    # If first uri doesn't match a RealmName, can't be one.
    if ($uri[0] !~ /^\w{3,}$/) {
	# Not a realm, so try SITE_ROOT
	_trace($orig_uri, ' => site_root') if $_TRACE;
	return ($_SITE_ROOT, $_GENERAL, '/'.$uri, $orig_uri);
    }

    # Try to find the uri with the realm replaced by placeholder
    # Replace realm with underscore.  This is ugly, but good enough for now.
    my($realm);
    # Up to which component is checked for path_info URI
    my($path_info_index) = undef;

    # Be friendly, by downcasing
    my($name) = lc($uri[0]);
    $uri[0] = $_REALM_PLACEHOLDER;

    # Is this a valid, authorized realm with a task for this uri?
    my($o) = Bivio::Biz::Model::RealmOwner->new($req);
    $req->throw_die(Bivio::DieCode::NOT_FOUND,
            {entity => $name, uri => $orig_uri,
                class => 'Bivio::Auth::Realm',
                message => 'no such realm'})
            unless $o->unauth_load(name => $name);
    $realm = Bivio::Auth::Realm->new($o);
    # Component after realm name must identify path_info URI
    $path_info_index = 1;

    # Found the realm, now try to find the URI (without checking path_info)
    $uri = join('/', @uri);
    my($rti) = $realm->get('type')->as_int;
    # No path info?
    if (defined($fields->{from_uri}->{$uri})
	    && defined($fields->{from_uri}->{$uri}->[$rti])) {
	_trace($orig_uri, ' => ', $fields->{from_uri}->{$uri}->[$rti]->{task})
		if $_TRACE;
	return ($fields->{from_uri}->{$uri}->[$rti]->{task}, $realm, '',
		$orig_uri);
    }

    # Is this a path_info URI?  Note this may seem a bit "slow", but it
    # is a rare case and NOT_FOUND processing is much faster than normal
    # requests anyway.
    $uri = join('/', @uri[0..$path_info_index]);
    if (defined($fields->{from_uri}->{$uri})
	    && defined($info = $fields->{from_uri}->{$uri}->[$rti])
	    && $info->{has_path_info}) {
	_trace($orig_uri, ' => ', $info->{task}) if $_TRACE;
	return ($info->{task}, $realm,
		'/'.join('/', @uri[$path_info_index+1..$#uri]), $orig_uri);
    }

    # Well, really not found
    $req->throw_die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
	realm_type => $realm->get('type')->get_name,
	orig_uri => $orig_uri,
	uri => $uri,
	message => 'no such URI for this realm'});
    # DOES NOT RETURN
}

=for html <a name="unsafe_get_from_uri"></a>

=head2 static unsafe_get_from_uri(string uri, Bivio::Auth::RealmType realm_type, Bivio::Collection::Attributes req_or_facade) : Bivio::Agent::TaskId

B<This is experimental.  Don't use widely just yet.>

Returns the TaskId for task identified by I<uri> and I<realm_type>.  Returns
C<undef> if no task is found.  Tasks with path_info should not include the
trailing "/*".

I<uri> will be implicitly prefixed by '?/' (realm placeholder) depending on
realm_type.

=cut

sub unsafe_get_from_uri {
    my($proto, $uri, $realm_type, $req_or_facade) = @_;
    my($self) = $proto->internal_get_self($req_or_facade);
    my($from_uri) = $self->{$_PACKAGE}->{from_uri};
    $uri = $_REALM_PLACEHOLDER.'/'.$uri if $realm_type ne $_GENERAL;
    _clean_uri(\$uri);
    my($info) = $from_uri->{$uri};
    return undef unless $info;
    $info = $info->[$realm_type->as_int];

#TODO: Is this really the same as what parse_uri() does?
    return $info ? $info->{task} : undef;
}

#=PRIVATE METHODS

# _clean_uri(string_ref uri)
#
# Removes dup and leading slashes
#
sub _clean_uri {
    my($uri) = @_;
    # Delete dup slashes and leading / (except '/' uri)
    $$uri =~ s/\/{2,}/\//g;
    $$uri =~ s/^\/(.)/$1/g;
    $$uri =~ s!^$!/!s;
    return;
}

# _get_error(self, array args) : string
#
# Returns a uri
#
sub _get_error {
    return shift->get_error(@_)->{uri};
}

# _init_basic(self)
#
# Ensures SITE_ROOT defined.
#
sub _init_basic {
    my($self) = @_;
    $self->internal_get_value('SITE_ROOT');
    return;
}

# _init_config(hash_ref fields, hash_ref value) : string
#
# Canonicalizes $value->{config} so that $value contains "uri" (array_ref)
# and maybe "help".
#
# Returns error message or success (undef).
#
sub _init_config {
    my($fields, $value) = @_;
    my($c) = $value->{config};
    if (ref($c) eq 'HASH') {
	# path_info must begin with '/'
	($value->{help} = $c->{help}) =~ s!^([^\/])!/$1!;
	# Must be last line, because we overwrite
	$c = $c->{uri};
    }
    if (ref($c) eq 'ARRAY') {
	# Don't share data structures with the config.  Allow empty
	# uri list to mean "undef".
	$value->{aliases} = @$c ? [@$c] : undef;
    }
    elsif (ref($c)) {
	return 'value is unknown reference type';
    }
    elsif (defined($c)) {
	$value->{aliases} = [$c];
    }
    else {
	$value->{aliases} = undef;
    }
    return;
}

# _init_err(self, hash_ref value, string msg, ...)
#
# Initializes $value as undef config and calls initialization_error,
# unless @msg is empty.
#
sub _init_err {
    my($self, $value, @msg) = @_;
    # Print message before changing $value
    $self->initialization_error($value, @msg) if @msg;

    $value->{uri} = $self->UNDEF_URI();
    $value->{is_valid} = 0;
    $value->{has_path_info} = 0;
    $value->{realm_type} = $_GENERAL;
    # This task must always be defined.
    $value->{task} = Bivio::Agent::TaskId->SITE_ROOT;
    return;
}

# _init_from_uri(self, array_ref groups)
#
# Creates the from_uri map.
#
sub _init_from_uri {
    my($self, $groups) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(%from_uri);
#TODO: Remove
#    my(%path_info_uri);
    foreach my $group (@$groups) {
	next unless $group->{is_valid} && $group->{aliases};
	my($rti) = $group->{realm_type}->as_int;
	foreach my $uri (@{$group->{aliases}}) {
	    # Save the URI in the map
	    if ($from_uri{$uri}) {
		if ($from_uri{$uri}->[$rti]) {
		    _init_err($self, $group,
			    "$uri $group->{realm_type}: uri already mapped to ",
			    $from_uri{$uri}->[$rti]->{task}->get_name);
		    next;
		}
	    }
	    else {
		$from_uri{$uri} = [];
	    }
	    $from_uri{$uri}->[$rti] = $group;
#TODO: remove possibly
#	    $path_info_uri{$uri}++ if $group->{has_path_info};
	}
    }

#TODO: This test isn't really useful.  You may want a general foo/* URI
#      and a specific "foo/bar" URI (task).  parse_uri will always route
#      to the more specific URI. 
#    # Make sure all URIs don't collide with path_info uris.
#    # document_task is special, because it is the only URI which begins
#    # with '/', so it doesn't match any other uris which can't begin
#    # with '/'.
#    foreach my $piu (keys(%path_info_uri)) {
#	foreach my $uri (keys(%from_uri)) {
#	    _init_err($uri, 'path_info uri collision with', $piu)
#		    if $uri =~ m!\Q$piu/!;
#	}
#    }

    $fields->{from_uri} = \%from_uri;
    return;
}

# _init_name(hash_ref fields, hash_ref value) : string
#
# Ensures $value->{names} is correct.  Sets realm_type.
#
# Returns error message or success (undef).
#
sub _init_name {
    my($fields, $value) = @_;

    return 'must be exactly one name' unless int(@{$value->{names}}) == 1;

    my($task_id_name) = uc($value->{names}->[0]);
    return 'name not a task_id'
	    unless $value->{task} = Bivio::Agent::TaskId->$task_id_name();

    my($realm_type_name) = $fields->{to_realm_type}->{$task_id_name};
    return 'no realm_type for task'
	    unless $realm_type_name;
    $value->{realm_type} = Bivio::Auth::RealmType->$realm_type_name();
    return;
}

# _init_uri(hash_ref fields, hash_ref value) : string
#
# Parses value->{uri} and sets uri, path_info, and possibly aliases.
# Updates fields->{from_uri} and fields->{path_info_uri}
#
# Returns error message or success (undef).
#
sub _init_uri {
    my($field, $value) = @_;
    unless ($value->{aliases}) {
	$value->{has_path_info} = 0;
	return;
    }

    my($first) = 1;
    my($aliases) = $value->{aliases};
    $value->{aliases} = [];
    foreach my $alias (@$aliases) {
	# Is this a path_info uri?  We remove the trailing /*, because
	# we want to allow for "empty" path info.
	my($has_path_info) = $alias =~ s/\/?\*$//;

	# Modify uri in place
	_clean_uri(\$alias);

	# Is the URI valid?
	my($path_info_count) = undef;
	if ($value->{realm_type} == Bivio::Auth::RealmType::GENERAL()) {
	    $path_info_count = $alias eq '/' ? 0 : 1;
	}
	else {
	    # URI with realm_owner
	    return "$alias: must begin with '$_REALM_PLACEHOLDER'"
		    unless $alias =~ m!^$_REALM_PLACEHOLDER_PAT(?:\/|$)!;
	    $path_info_count = 2;
	}

	# Make sure there is exactly one trailing component
	# for path_info URIs
	if ($has_path_info) {
	    my(@x) = split(/\//, $alias);
	    return "$alias: path_info uris must contain $path_info_count"
		    ." components"
			    unless int(@x) == $path_info_count;
	    return "$alias: aliases must not have path_info"
		    ." if primary uri does not have it"
		    if exists($value->{has_path_info})
			    && !$value->{has_path_info};
	}
	# Else, converse is not true.  It's ok to map a uri which doesn't
	# have path info with a primary uri which does have path_info

	# Save the alias and setup main uri
	push(@{$value->{aliases}}, $alias);
	next unless $first;
	$value->{has_path_info} = $has_path_info ? 1 : 0;
	$value->{uri} = $alias;
	$first = 0;
    }
    return;
}

# _initialize_fields(self) : hash_ref
#
# Initializes $self->{$_PACKAGE} during new. 
#
sub _initialize_fields {
    my($self) = @_;
    return $self->{$_PACKAGE} if $self->{$_PACKAGE};
    return $self->{$_PACKAGE} = {
	# Used only at initialization
	to_realm_type => {map {
	    (uc($_->[0]) => uc($_->[2]));
	} @{Bivio::Agent::TaskId->get_cfg_list}},
    };
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
