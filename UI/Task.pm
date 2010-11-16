# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Task;
use strict;
use Bivio::Base 'UI.FacadeComponent';
use Bivio::IO::Trace;

# C<Bivio::UI::Task> provides URIs for tasks.  There are two uris currently
# provided: L<format_uri|"format_uri"> and L<format_help_uri|"format_help_uri">.
#
# Tasks are configured as follows:
#
#      group(<TASK_NAME> => <uri>);
#      group(<TASK_NAME> => {
#          uri => <uri>,
#          help => <help-path-info>,
#      });
#      group(<TASK_NAME> => {
#          uri => [<primary-uri>, <alias1>, <alias2>, ...],
#          help => <help-path-info>,
#      });
#
# The first case is simply a shorthand for the second without a I<help>
# attribute.
#
# The I<uri> is a relative path to the task which starts at the root of the site
# (/).  The I<uri> may be a list in which case the first URI is the one returned
# by L<format_uri|"format_uri">.
#
# Choose your I<uri>s carefully.  We recommend using dash/minus (-) to separate
# values within the same uri component, e.g. my-component vs. my_component.
# Dashes are readable when underlined and they are legal URI characters.
#
# A I<uri> may contain a realm name (see special characters below).  We restrict
# this to the top level name in the space.  This is an efficiency concern, but it
# is also pragmatic.  It enforces a practical naming convention which allows you
# to avoid collisions between reserved realm names (see
# L<Bivio::Type::RealmName|Bivio::Type::RealmName>) and URI components.  Indeed
# we give these URIs a special name: I<realm owner relative> (ROR).
#
# I<uri> may contain special characters as follows:
#
#
# ?
#
# Question mark (?) identifies a I<realm owner relative> (ROR) uri.  The URI
# operates in a security realm (CLUB, USER, etc.).  The question mark (?) is a
# placeholder for a realm owner name, e.g.  ?/accounting would map to
# my_club/accounting if my_club were the current realm owner name.  It may appear
# as the first component of the path only, e.g. C<?/edit/address> but not
# C<edit/?/address>.  During rendering, the value will be filled in with the
# passed in realm name or the I<auth_realm> on the request.
#
# *
#
# May appear as the trailing component of the URI, e.g. /help/*.  We restrict
# path info to the second component in ownerless URIs (no question marks) and the
# third component in ROR uris.  An incoming URI will be parsed and the
# I<path_info> will be placed on the request.  An outgoing URI will have
# I<path_info> appended (see L<format_uri|"format_uri">).
#
#
#
#
# HELP
#
# The task which L<format_help_uri|"format_help_uri"> uses to format uris.
# This task must have a I<help> attribute which is where help is routed
# to.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_RN) = b_use('Type.RealmName');
my($_R) = b_use('Auth.Realm');
my($_RT) = b_use('Auth.RealmType');
my($_GENERAL) = $_R->get_general;
my($_GENERAL_TYPE) = $_RT->GENERAL;
my($_ANY_OWNER_INT) = $_RT->ANY_OWNER->as_int;
my($_REALM_PLACEHOLDER) = '?';
my($_REALM_PLACEHOLDER_PAT) = $_REALM_PLACEHOLDER;
$_REALM_PLACEHOLDER_PAT =~ s/(\W)/\\$1/g;
# Map of realm types to default realm placeholders
my($_TI) = b_use('Agent.TaskId');
my($_FCT) = b_use('FacadeComponent.Text');
my($_AT) = b_use('Agent.Task');
my($_SEOP) = b_use('Cache.SEOPrefix');

sub HELP {
    return $_TI->HELP;
}

sub HELP_INDEX {
    # Index for help tree.
    return '/index.html';
}

sub UNDEF_CONFIG {
    # Returns a hash with a special key.
    return {
	undef_config => 1,
    };
}

sub UNDEF_URI {
    # URI to use when task is not found or error converting to URI.
    return 'TASK-ERR';
}

sub assert_defined_for_facade {
    my($proto, $task, $req_or_facade) = @_;
    my($v) = $proto->internal_get_value($task->get_name, $req_or_facade);
    b_die('NOT_FOUND', {
	entity => $task,
	message => 'no such task in facade',
    }) unless $v->{is_valid};
    return;
}

sub assert_uri {
    my($self, $task, $req) = @_;
    return shift->internal_get_self($req)->assert_uri(@_)
	unless ref($self);
    my($n) = $_TI->from_any($task)->get_name;
    b_die($n, ': no uri associated with task')
	unless $self->internal_get_value($n)->{uri};
    return;
}

sub format_css {
    my($proto, $task_name, $req) = @_;
    return $proto->format_uri({
	task_id => $task_name,
	realm => undef,
	path_info => undef,
	query => undef,
	no_context => 1,
    }, $req);
}

sub format_help_uri {
    my($self, $task, $req) = @_;
    return shift->internal_get_self($req)->format_help_uri(@_)
	unless ref($self);
    my($info) = $task
	? $self->internal_get_value(ref($task) ? $task->get_name  : $task)
	: undef;
    return $self->format_uri(
	{
	    task_id => $self->HELP,
	    realm => undef,
	    path_info => $info && $info->{help} ? $info->{help}
		: $_FCT->get_value('help_index_path_info', $req),
	    no_context => 0,
	},
	$req,
    );
}

sub format_realmless_uri {
    my($self, $task_id, $path_info, $req) = @_;
    return shift->internal_get_self($req)->format_realmless_uri(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    return $self->format_uri(
	{
	    task_id => $_TI->from_any($task_id),
	    realm => $fields->{realmless_uri}->{
		$_AT->get_by_id($task_id)->get('realm_type')
	    },
	    path_info => $path_info,
	    no_context => 1,
	},
	$req,
    );
}

sub format_uri {
    my($self, $named, $req) = @_;
    return shift->internal_get_self($req)->format_uri(@_)
	unless ref($self);
    b_die('named parameters only')
	unless ref($named) eq 'HASH';
    return _seo_uri_prefix($self, $named->{uri}, $named, $req)
	if defined($named->{uri});
    $named->{task_id} = $_TI->from_name($named->{task_id})
	unless ref($named->{task_id});
    my($task_name) = $named->{task_id}->get_name;
    my($info) = $self->internal_get_value($task_name);
    return _get_error($self, $task_name)
  	unless defined(my $uri = $info->{uri});
    if ($uri =~ /$_REALM_PLACEHOLDER_PAT/o) {
	$named->{realm} = $self->[$_IDI]->{realmless_uri}->{$info->{realm_type}}
	    || return _get_error($self, $task_name,
		'uri requires a realm but not defined nor is there a'
		. ' realmless_uri configured for ', $info->{realm_type})
	    unless defined($named->{realm});
	my($ro);
	if (ref($named->{realm})) {
	    $ro = $named->{realm}->unsafe_get('owner_name')
		|| b_die($task_name, ': task requires named realm');
	}
	else {
	    return _get_error(
		$self,
		$task_name,
		$named->{realm},
		' not a simple realm name or placeholder'
	    ) unless $ro = $_RN->unsafe_from_uri($named->{realm});
	}
	$uri =~ s/.*?$_REALM_PLACEHOLDER_PAT/\/$ro/og;
    }
    $uri = '/' . $uri
	unless $uri =~ /^\//;
    if ($info->{has_path_info} && defined($named->{path_info})) {
	$uri =~ s{/$}{};
	$uri .= Bivio::HTML->escape_uri(
	    ($named->{path_info} =~ m{^/} ? '' : '/') . $named->{path_info},
	);
	$uri =~ s{(.)/$}{$1};
    }
    $uri =~ s{//+}{/}g;
    $named->{no_form} = 1
	unless exists($named->{no_form});
    return _seo_uri_prefix($self, $uri, $named, $req)
        . Bivio::Biz::FormModel->format_context_as_query(
	    $req->get_form_context_from_named($named),
	    $req,
	);
}

sub handle_register {
    my($proto) = @_;
    b_use('UI.Facade')->register($proto, ['Text']);
    return;
}

sub has_help {
    my($self, undef, $req) = @_;
    return shift->internal_get_self($req)->has_help(@_)
	unless ref($self);
    return _has('help', @_);
}

sub has_uri {
    my($self, undef, $req) = @_;
    return shift->internal_get_self($req)->has_uri(@_)
	unless ref($self);
    return _has('uri', @_);
}

sub initialization_complete {
    my($self) = @_;
    # Generates internal tables.
    my($fields) = _initialize_fields($self);
    delete($fields->{to_realm_type});
    _init_from_uri($self, $self->internal_get_all_groups);
    # Map default placeholders for these realms.  See format_realmless_uri().
    $fields->{realmless_uri} = {
	map(($_ => ($self->internal_unsafe_lc_get_value(
	    $_->get_name . '_REALMLESS_REDIRECT') || {})->{uri}),
	    $_RT->get_list),
#TODO: Remove my_club_site and my_site requirements
	# You can't format realmless unless these tasks exist.
	$_RT->CLUB
	    => $self->internal_get_value('my_club_site')->{uri},
	$_RT->USER
	    => $self->internal_get_value('my_site')->{uri},
	$_RT->GENERAL => undef,
    };
    return shift->SUPER::initialization_complete(@_);
}

sub internal_initialize_value {
    my($self, $value) = @_;
    # Sets up the attributes for this value.  There can be no grouped values, so we
    # check to make sure I<names> is a single value.  C<undef> causes
    # L<UNDEF_URI|"UNDEF_URI"> to be mapped.  We set I<from_uri>
    # and I<placeholder> here.
    my($fields) = _initialize_fields($self);
    # Special case undefined value
    return _init_err($self, $value)
	if ref($value->{config}) eq 'HASH' && $value->{config}->{undef_config};
    foreach my $s (\&_init_config, \&_init_name, \&_init_uri) {
	my($err) = $s->($fields, $value);
	return _init_err($self, $value, $err)
	    if $err;
    }
    $value->{is_valid} = 1;
    return;
}

sub internal_setup_facade {
    my($proto, $req) = @_;
    my($f) = b_use('UI.Facade');
    return ref($proto) ? $proto
        : ($req->unsafe_get($f) || $f->setup_request(
	    $req->unsafe_get('r') && $req->get('r')->hostname || undef, $req)
        )->get($proto->simple_package_name);
}

sub is_defined_for_facade {
    my($self, undef, $req) = @_;
    return shift->internal_get_self($req)->is_defined_for_facade(@_)
	unless ref($self);
    return _has('is_valid', @_);
}

sub is_not_found {
    my(undef, $value) = @_;
    return $value->{realm_type}->eq_general
	&& $value->{task}->get_name eq 'DEFAULT_ERROR_REDIRECT_NOT_FOUND'
        ? 1 : 0;
}

sub new {
    # Returns a new Task instance.
    return shift->SUPER::new(@_);
}

sub parse_uri {
    my($self, $orig_uri, $req) = @_;
    return shift->internal_setup_facade($req)->parse_uri(@_)
        unless ref($self);
    my($fields) = $self->[$_IDI];
    my($uri) = _seo_uri_prefix_strip($orig_uri);
    unless (length($uri)) {
	_trace($orig_uri,  '=> special case root') if $_TRACE;
	return ($fields->{site_root}, $_GENERAL, '', '/', '/');
    }
    my(@uri) = split(m{/+}, $uri);
    $uri = join('/', @uri);
    my($initial_uri) = "/$uri";
    return _parse_err($self, $orig_uri, $initial_uri, $req, {
	entity => $orig_uri,
	message => 'contains special char',
    }) if grep($_ eq $_REALM_PLACEHOLDER, @uri);
    my($info);
    return (
	_task($self, $info, $orig_uri),
	$_GENERAL,
	'',
	$orig_uri,
	$initial_uri,
    ) if $info = _from_uri($fields, $uri, $_GENERAL_TYPE);
    if ($info = _from_uri($fields, $uri[0], $_GENERAL_TYPE)) {
	return (
	    _task($self, $info, $orig_uri),
	    $_GENERAL,
	    '/'.join('/', @uri[1..$#uri]),
	    $orig_uri,
	    $initial_uri,
	) if $info->{has_path_info};
	return _parse_err($self, $orig_uri, $initial_uri, $req, {
	    entity => $orig_uri,
	    orig_uri => $orig_uri,
	    uri => $uri,
	    message => 'no such general URI (not a path_info uri)',
	});
    }
    my($name) = $_RN->unsafe_from_uri($uri[0]);
    unless (defined($name) && $self->has_uri($_TI->USER_HOME)) {
	_trace($orig_uri, ' => site_root (no name or no USER_HOME uri')
	    if $_TRACE;
	return (
	    $fields->{site_root},
	    $_GENERAL,
	    '/'.$uri,
	    $orig_uri,
	    $initial_uri,
	);
    }
    my($realm);
    my($path_info_index) = undef;
    $uri[0] = $_REALM_PLACEHOLDER;
    my($o) = Bivio::Biz::Model->new($req, 'RealmOwner');
    return _parse_err($self, $orig_uri, $initial_uri, $req, {
	entity => $name, uri => $orig_uri,
	class => $_R,
	message => 'no such realm',
    }) unless $o->unauth_load({name => $name});
    $realm = $_R->new($o);
    $uri = join('/', @uri);
    my($rt) = $realm->get('type');
    return (
	_task($self, $info, $orig_uri),
	$realm,
	'',
	$orig_uri,
	$initial_uri,
    ) if $info = _from_uri($fields, $uri, $rt);
    $path_info_index = 1;
    $uri = join('/', @uri[0..$path_info_index])
	if @uri > $path_info_index;
    return (
	_task($self, $info, $orig_uri),
	$realm,
	join('/', '', @uri[$path_info_index+1..$#uri]),
	$orig_uri,
	$initial_uri,
    ) if $info = _from_uri($fields, $uri, $rt) and $info->{has_path_info};
    return _parse_err($self, $orig_uri, $initial_uri, $req, {
	entity => $orig_uri,
	realm_type => $realm->get('type')->get_name,
	orig_uri => $orig_uri,
	uri => $uri,
	message => 'no such URI for this realm',
    });
}

sub unsafe_get_from_uri {
    my($proto, $uri, $realm_type, $req_or_facade) = @_;
    # B<This is experimental.  Don't use widely just yet.>
    #
    # Returns the TaskId for task identified by I<uri> and I<realm_type>.  Returns
    # C<undef> if no task is found.  Tasks with path_info should not include the
    # trailing "/*".
    #
    # I<uri> will be implicitly prefixed by '?/' (realm placeholder) depending on
    # realm_type.
    my($self) = $proto->internal_get_self($req_or_facade);
    $uri = "$_REALM_PLACEHOLDER/$uri"
	unless $realm_type->eq_general;
    _clean_uri(\$uri);
    return undef
	unless my $info = _from_uri($self->[$_IDI], $uri, $realm_type);
#TODO: Is this really the same as what parse_uri() does?
    return _task($self, $info);
}

sub _clean_uri {
    my($uri) = @_;
    # Removes dup and leading slashes
    # Delete dup slashes and leading / (except '/' uri)
    $$uri =~ s/\/{2,}/\//g;
    $$uri =~ s/^\/(.)/$1/g;
    $$uri =~ s!^$!/!s;
    return;
}

sub _from_uri {
    my($fields, $uri, $realm_type) = @_;
    return undef
	unless my $res = $fields->{from_uri}->{$uri};
    return $res->[$realm_type->as_int]
	|| $realm_type->equals_or_any_owner_check && $res->[$_ANY_OWNER_INT]
	|| undef;
}

sub _get_error {
    # Returns a uri
    return shift->get_error(@_)->{uri};
}

sub _has {
    my($which, $proto, $task_id, $req_or_facade) = @_;
    # Tests whether $which exists for $task_id
    return defined(
	($proto->internal_get_self($req_or_facade)
	    ->internal_unsafe_lc_get_value(
		ref($task_id) ? $task_id->get_name : $task_id)
	|| {})->{$which}
    ) ? 1 : 0;
}

sub _init_config {
    my($fields, $value) = @_;
    # Canonicalizes $value->{config} so that $value contains "uri" (array_ref)
    # and maybe "help".
    #
    # Returns error message or success (undef).
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

sub _init_err {
    my($self, $value, @msg) = @_;
    # Initializes $value as undef config and calls initialization_error,
    # unless @msg is empty.
    my($fields) = $self->[$_IDI];
    # Print message before changing $value
    $self->initialization_error($value, @msg) if @msg;

    $value->{uri} = $self->UNDEF_URI();
    $value->{is_valid} = 0;
    $value->{has_path_info} = 0;
    $value->{realm_type} = $_GENERAL;
    # This task must always be defined.
    $value->{task} = undef;
    return;
}

sub _init_from_uri {
    my($self, $groups) = @_;
    # Creates the from_uri map.
    my($fields) = $self->[$_IDI];
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
		    _init_err(
			$self, $group, $uri, ' ',
			$group->{realm_type}, ': uri already mapped to ',
			$from_uri{$uri}->[$rti]->{task}->get_name,
		    );
		    next;
		}
	    }
	    else {
		if ($uri eq '/' && $group->{realm_type}->eq_general) {
		    die('site_root must have path_info')
			unless $group->{has_path_info};
		    $fields->{site_root} = $group->{task};
		}
		$from_uri{$uri} = [];
	    }
	    $from_uri{$uri}->[$rti] = $group;
	}
    }
    die('must define a uri as /*')
	unless $fields->{site_root};
    $fields->{from_uri} = \%from_uri;
    return;
}

sub _init_name {
    my($fields, $value) = @_;
    return 'must be exactly one name'
	unless int(@{$value->{names}}) == 1;
    return 'name not a task_id'
	unless $value->{task}
	= $_TI->unsafe_from_name($value->{names}->[0]);
    return 'no realm_type for task'
	unless my $rtn = $fields->{to_realm_type}->{$value->{task}->get_name};
    $value->{realm_type} = $_RT->from_any($rtn);
    $fields->{not_found} = $value
	if __PACKAGE__->is_not_found($value);
    return;
}

sub _init_uri {
    my($field, $value) = @_;
    # Parses value->{uri} and sets uri, path_info, and possibly aliases.
    # Updates fields->{from_uri} and fields->{path_info_uri}
    #
    # Returns error message or success (undef).
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
	if ($value->{realm_type}->eq_general) {
	    $path_info_count = $alias eq '/' ? 0 : 1;
	    return "$alias: URIs for general realm must NOT begin with '$_REALM_PLACEHOLDER' "
		if $alias =~ m{^/*$_REALM_PLACEHOLDER_PAT};
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

sub _initialize_fields {
    my($self) = @_;
    # Initializes $self->[$_IDI] during new. 
    return $self->[$_IDI] if $self->[$_IDI];
    return $self->[$_IDI] = {
	# Used only at initialization
	to_realm_type => {map {
	    (uc($_->{name}) => uc($_->{realm_type}));
	} @{$_TI->get_cfg_list}},
    };
}

sub _parse_err {
    my($self, $orig_uri, $initial_uri, $req, $attrs) = @_;
    my($fields) = $self->[$_IDI];
    $req->throw_die('NOT_FOUND', $attrs)
	unless my $t = $fields->{not_found};
    return ($t->{task}, $_GENERAL, '', $orig_uri, $initial_uri);
}

sub _seo_uri_prefix {
    my($self, $uri, $named, $req) = @_;
    return $uri
	unless $uri =~ m{^/};
    my($sup) = $named->{seo_uri_prefix};
    unless ($sup) {
	return $uri
	    unless $sup = $_SEOP->find_prefix_by_uri($uri, $req);
    }
    $sup =~ s/([\W]+)/-/g;
    $uri = "/$sup-$uri"
	if $sup && $sup ne '-';
    return $uri;
}

sub _seo_uri_prefix_strip {
    my($uri) = @_;
    $uri =~ s{^/+}{};
    $uri =~ s{^[^/]*-(?:$|/+)}{};
    return $uri;
}

sub _task {
    my($self, $info, $orig_uri) = @_;
    # Returns task or site_root
    _trace($orig_uri, ' => ', $info->{task})
	if $orig_uri && $_TRACE;
    return $info->{task} || $self->[$_IDI]->{site_root};
}

1;
