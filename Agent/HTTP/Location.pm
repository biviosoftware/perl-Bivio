# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Location;
use strict;
$Bivio::Agent::HTTP::Location::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::HTTP::Location::VERSION;

=head1 NAME

Bivio::Agent::HTTP::Location - provides URL to realm/task_id mapping

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Location;
    Bivio::Agent::HTTP::Location->parse($uri);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::HTTP::Location::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Location> maps a URI to a
L<Bivio::Auth::Realm|Bivio::Auth::Realm> and a
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

When adding new syntax to the configuration table, default to a restrictive
set.  We don't know the path this module will be taking over the years,
so we should try to be as simple as possible until we know otherwise.

=cut


=head1 CONSTANTS

=cut

=for html <a name="REALM_PLACEHOLDER"></a>

=head2 REALM_PLACEHOLDER : string

Returns the placeholder for the realm in a URI configuration.

=cut

sub REALM_PLACEHOLDER {
    return '?';
}

#=IMPORTS
# Avoid anything that might access the db here.  Add it in
# (if need be) in initialize() explicitly.
use Bivio::Die;
use Bivio::HTML;
use Bivio::Agent::TaskId;
use Bivio::Auth::RealmType;
use Bivio::DieCode;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Carp ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_INITIALIZED) = 0;
# Key is uri, value is array indexed by RealmType->as_int, whose value
# is a a hash with keys (task, uri)
my(%_FROM_URI);
# Key is task_id, value is alias to _FROM_URI value (for realm)
my(%_FROM_TASK_ID);
# TaskId of task which serves documents
my($_DOCUMENT_TASK);
my($_GENERAL_INT) = Bivio::Auth::RealmType->GENERAL->as_int;
my($_GENERAL);
my($_DOCUMENT_ROOT) = undef;
my($_HELP_ROOT) = undef;
Bivio::IO::Config->register({
    document_root => Bivio::IO::Config->REQUIRED,
});
my($_REALM_PLACEHOLDER_PAT) = REALM_PLACEHOLDER();
$_REALM_PLACEHOLDER_PAT =~ s/(\W)/\\$1/g;
# Map of realm types to default realm placeholders
my(%_PLACEHOLDER);

=head1 METHODS

=cut

=for html <a name="find_task"></a>

=head2 static find_task(string uri, Bivio::Auth::RealmType realm_type) : Bivio::Agent::TaskId

B<This is experimental.  Don't use widely just yet.>

Returns the TaskId for task identified by I<uri> and I<realm_type>.  Returns
C<undef> if no task is found.  Tasks with path_info should not include the
trailing "/*".

=cut

sub find_task {
    my(undef, $uri, $realm_type) = @_;
    my($info) = $_FROM_URI{$uri};
    return undef unless $info;
    $info = $info->[$realm_type->as_int];
#TODO: Could really do what code in parse does.
    return $info ? $info->{task} : undef;
}

=for html <a name="format"></a>

=head2 static format(Bivio::Agent::TaskId task_id, Bivio::Auth::Realm realm, Bivio::Agent::Request req, boolean no_context, string path_info) : string

=head2 static format(Bivio::Agent::TaskId task_id, string realm_name, Bivio::Agent::Request req, boolean no_context, string path_info) : string

Transforms I<task_id> and I<realm> (if needed) into a URI.
I<realm_name> must be a legitimate realm name.

B<path_info is not escaped>

=cut

sub format {
    my(undef, $task_id, $realm, $req, $no_context, $path_info) = @_;
    Bivio::Die->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    my($info) = $_FROM_TASK_ID{$task_id};
    my($uri) = $info->{uri};
    Bivio::Die->die($task_id, ': task has no uri')
	    unless defined($uri);

#TODO: Add in the form context with \& at the end which turns into nothing
# if no context added.
    # URI contains a question mark
    if ($uri =~ /$_REALM_PLACEHOLDER_PAT/o) {
	Bivio::Die->die('uri requires but realm not defined')
		    unless defined($realm);
	my($ro);
	if (ref($realm)) {
	    # If the realm doesn't have an owner, there's a bug somewhere
	    $ro = $realm->get('owner_name');
	}
	else {
	    # We're a little strict here, since we added this overload later
	    Bivio::Die->die($realm, ': not a simple realm name or placeholder')
			unless $realm =~ /^[-\w]+$/;
	    $ro = $realm;
	}
	# Replace everything leading up to placeholder with the uri prefix
	$uri =~ s/.*$_REALM_PLACEHOLDER_PAT/$ro/og;
    }
    $uri = '/'.$uri unless $uri =~ /^\//;

    # Append path_info, if necessary.  Note that we don't check for
    # "defined", because path_info is returned as '' from "parse".
    # We do this so we can handle safely in various bits of code.
    # path_info must begin with a '/' if it is set.
    if ($info->{has_path_info}) {
	if ($path_info) {
	    Bivio::Die->die($task_id, '(', $uri, '): missing path_info')
			unless $path_info;
	    Bivio::Die->die($task_id, '(', $uri,
		    '): path_info must begin with slash (', $path_info, ')')
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

#TODO: Hack.  Recursion in FormModel otherwise
    return $uri if $no_context;

#TODO: Tightly coupled with UI::HTML::Widget::Form.
    my($rc) = Bivio::Agent::Task->get_by_id($task_id)->get('require_context');
    $uri .= Bivio::Biz::FormModel->format_context_as_query($req, $task_id)
	    if $rc;
    return $uri;
}

=for html <a name="format_realmless"></a>

=head2 static format_realmless(Bivio::Agent::TaskId task_id) : string

Formats a stateless, realmless URI.  It uses my-club-site or
my-site for the realm in the URI.

This is an experimental method.

=cut

sub format_realmless {
    my($proto, $task_id) = @_;
    Bivio::Die->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    return $proto->format(
	    $task_id,
	    $_PLACEHOLDER{$_FROM_TASK_ID{$task_id}->{realm_type}},
	    undef,
	    1,
	    undef);
}

=for html <a name="get_document_root"></a>

=head2 get_document_root() : string

Returns the document root.

=cut

sub get_document_root {
    die(__PACKAGE__, 'not initialized') unless $_DOCUMENT_ROOT;
    return $_DOCUMENT_ROOT;
}

=for html <a name="get_help_path_info"></a>

=head2 static get_help_path_info(string topic) : string

Returns the path_info to be passed to HELP task for this topic.

=cut

sub get_help_path_info {
    my(undef, $topic) = @_;
    Bivio::Die->die($topic, ': invalid help topic')
		unless $topic =~ /^[\w-]+$/;
#TODO: This presumes a lot.  Too much?
    $topic = '/'.$topic.'.html';
    Bivio::Die->die($topic, ': help file not found')
		unless $_HELP_ROOT.$topic;
    return $topic;
}

=for html <a name="get_help_root"></a>

=head2 get_help_root() : string

Returns the help system root.

=cut

sub get_help_root {
    die(__PACKAGE__, 'not initialized') unless $_HELP_ROOT;
    return $_HELP_ROOT;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item document_root : string (required)

If defined, URIs not found by the normal mechanism will be sought
for in this directory.  The realm is specified by
C<HTTP_DOCUMENT> task.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_DOCUMENT_ROOT = $cfg->{document_root};
    die("$_DOCUMENT_ROOT: not a directory") unless -d $_DOCUMENT_ROOT;
    $_DOCUMENT_ROOT =~ s!([^/])$!$1/!;
    return;
}

=for html <a name="initialize"></a>

=head2 static initialize()

Initialize from syntax as defined in TaskId.  We take special care to
enforce all the syntax rules at compile time.

Simple utilities can probably use L<initialize_map|"initialize_map">
instead of this routine.

=cut

sub initialize {
    return if $_INITIALIZED;
    $_INITIALIZED = 1;

    my($proto) = @_;
    $proto->initialize_map;

    # The following tasks require IO::Config and the database.
    Bivio::IO::ClassLoader->simple_require(qw(
         Bivio::Auth::Realm::General
         Bivio::Auth::Realm
    ));

    $_GENERAL = Bivio::Auth::Realm::General->new;

    # Make sure HTTP_DOCUMENT is defined
    $_DOCUMENT_TASK = $_FROM_TASK_ID{Bivio::Agent::TaskId::HTTP_DOCUMENT()}
	    ->{task};
    die('HTTP_DOCUMENT: task must be configured') unless $_DOCUMENT_TASK;

    # Configure HELP_ROOT
    my($help) = $_FROM_TASK_ID{Bivio::Agent::TaskId::HELP()};
    die('HELP: task not configured') unless $help;
    $_HELP_ROOT = $_DOCUMENT_ROOT.$help->{uri};
    die("HELP_ROOT: $_HELP_ROOT: not a directory") unless -d $_HELP_ROOT;

    return;
}

=for html <a name="initialize_map"></a>

=head2 initialize_map()

This is a partial initialization of the parts of this module which
don't require the database.  It is here to support simple utilities.

=cut

sub initialize_map {
    return if %_FROM_URI;
    my($cfg) = Bivio::Agent::TaskId->get_cfg_list;
    my(%path_info_uri);
    foreach my $c (@$cfg) {
	my($task_id_name, $realm_type_name, $uri_list) = @{$c}[0,2,4];
	my($task_id) = Bivio::Agent::TaskId->$task_id_name();

#TODO: Shouldn't know that GENERAL is a special realm(?)
	# Test for all the realms we understand, explicitly.
	my($realm_type) = Bivio::Auth::RealmType->$realm_type_name();
	my($rti) = $realm_type->as_int;
	my($uri);

	# Make sure we have at least one URI (use '!' if you don't want a uri)
	my($got_one) = 0;
	# Reverse so first one is the one used in the _FROM_TASK_ID map
	foreach $uri (reverse(split(/:/, $uri_list))) {
	    $got_one++;
	    my($has_path_info) = 0;
	    if ($uri eq '!') {
		# Special case: empty uri
		$uri = undef;
	    }
	    else {
		# Is this a path_info uri?  We remove the trailing /*, because
		# we want to allow for "empty" path info
		$has_path_info = $uri =~ s/\/\*$//;
		$uri = '/' unless length($uri);

		# Delete dup slashes and leading / (except DOC ROOT task)
		$uri =~ s/\/{2,}/\//g;
		$uri =~ s/^\/(.)/$1/g;

		# Is the URI valid?
		my($path_info_count) = undef;
		if ($realm_type == Bivio::Auth::RealmType::GENERAL()) {
		    $path_info_count = $uri eq '/' ? 0 : 1;
		}
		else {
		    # URI with realm_owner
                    die("$task_id_name: $uri: must begin with '"
                            .REALM_PLACEHOLDER()."'")
                            unless $uri =~ m!^$_REALM_PLACEHOLDER_PAT(?:\/|$)!;
                    $path_info_count = 2;
		}
		# Make sure there is exactly one trailing component
		# for path_info URIs
		if ($has_path_info) {
		    my(@x) = split(/\//, $uri);
		    die("$task_id_name: $uri: path_info uris must"
			    ." contain $path_info_count components")
			    if int(@x) != $path_info_count;
		}

		# Save the URI in the map
		if ($_FROM_URI{$uri}) {
		    die("$task_id_name: $uri $realm_type_name: uri already"
			    .' mapped to ',
			    $_FROM_URI{$uri}->[$rti]->{task}->get_name)
			    if $_FROM_URI{$uri}->[$rti];
		}
		else {
		    $_FROM_URI{$uri} = [];
		}
	    }

	    # Save off information in maps
	    my($info) = {
		task => $task_id,
		uri => $uri,
		realm_type => $realm_type,
		has_path_info => $has_path_info ? 1 : 0,
	    };
	    $_FROM_URI{$uri}->[$rti] = $info if defined($uri);
	    $_FROM_TASK_ID{$task_id} = $info;
	    $path_info_uri{$uri}++ if $has_path_info;
	}
	die("$task_id_name: must have at least on uri, use '!' for blank")
		unless $got_one;
    }

    # Make sure all URIs don't collide with path_info uris.
    # DOCUMENT_TASK is special, because it is the only URI which begins
    # with '/'.
    foreach my $piu (keys(%path_info_uri)) {
	foreach my $uri (keys(%_FROM_URI)) {
	    die("URI ($uri) collides with path_info uri ($piu)")
		    if $uri =~ m!\Q$piu/!;
	}
    }

#TODO: Is this a hack?
    # Map default placeholders for these realms.  See format_realmless().
    $_PLACEHOLDER{Bivio::Auth::RealmType::CLUB()}
	    = $_FROM_TASK_ID{Bivio::Agent::TaskId::MY_CLUB_SITE()}
	    ->{uri};
    $_PLACEHOLDER{Bivio::Auth::RealmType::USER()}
	    = $_FROM_TASK_ID{Bivio::Agent::TaskId::MY_SITE()}
	    ->{uri};
    $_PLACEHOLDER{Bivio::Auth::RealmType::GENERAL()} = undef;

    return;
}

=for html <a name="parse"></a>

=head2 static parse(string uri, Bivio::Agent::Request req) : array

Returns I<task_id>, I<auth_realm>, I<path_info>, and new I<uri> for I<uri>.

Note that the I<path_info> is left on the URI.

=cut

sub parse {
    my($proto, $req, $uri) = @_;

#TODO: Need to make Location a separate module.
    # We don't set the facade if the request already has one,
    # because parse is currently called from more than one place
    # during the request.
    my($facade) = $uri =~ s/^\/*\*(\w+)// ? $1 : undef;
    $proto->setup_facade($facade, $req) unless $req->has_keys('facade');

    my($orig_uri) = $uri;
    $uri =~ s!^/+!!;

    # Special case: '/' or ''
    unless (length($uri)) {
	$req->put(initial_uri => '/');
	return ($_DOCUMENT_TASK, $_GENERAL, '', '/');
    }

    # Question mark is a special character
    my(@uri) = map {
	$req->throw_die(Bivio::DieCode::NOT_FOUND,
		{entity => $orig_uri, message => 'contains special char'})
		if $_ eq REALM_PLACEHOLDER();
	$_;
    } split(/\/+/, $uri);

    # There is always something in $uri and @uri at this point
    $uri = join('/', @uri);
    my($info);
    $req->put(initial_uri => '/'.$uri);

    # General realm simple map; no placeholders or path_info.
    return ($info->{task}, $_GENERAL, '', $orig_uri)
	    if defined($info = $_FROM_URI{$uri}->[$_GENERAL_INT]);

    # Is this a general realm with path_info?  URI has at least
    # one component.
    if (defined($info = $_FROM_URI{$uri[0]}->[$_GENERAL_INT])) {
	# At this stage, we have to map to a general realm, because
	# all first components of the general realm are not valid
	# Bivio::Type::RealmName values.  Therefore, we fail with
	# not found if it matches the first component, but there
	# isn't a task for realm_info.
	return ($info->{task}, $_GENERAL, '/'.join('/', @uri[1..$#uri]),
                $orig_uri) if $info->{has_path_info};

	# The URI doesn't accept path_info, so not found.
	$req->throw_die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
	    orig_uri => $orig_uri,
	    uri => $uri,
	    message => 'no such general URI (not a path_info uri)'});
    }

    # If first uri doesn't match a RealmName, can't be one.
    if ($uri[0] !~ /^\w{3,}$/) {
	# Not a realm, but is it a document and is it found?
	return ($_DOCUMENT_TASK, $_GENERAL, '/'.$uri, $orig_uri)
		if defined($_DOCUMENT_ROOT) && -e ($_DOCUMENT_ROOT.$uri);

	# Not found
	$req->throw_die(Bivio::DieCode::NOT_FOUND, {uri => $orig_uri,
	    entity => $_DOCUMENT_ROOT.$uri,
	    message => 'no such document'});
    }

    # Try to find the uri with the realm replaced by placeholder
    # Replace realm with underscore.  This is ugly, but good enough for now.
    my($realm);
    # Up to which component is checked for path_info URI
    my($path_info_index) = undef;

    # Be friendly, by downcasing
    my($name) = lc($uri[0]);
    $uri[0] = REALM_PLACEHOLDER();

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
    return ($_FROM_URI{$uri}->[$rti]->{task}, $realm, '', $orig_uri)
	    if defined($_FROM_URI{$uri}) && defined($_FROM_URI{$uri}->[$rti]);

    # Is this a path_info URI?  Note this may seem a bit "slow", but it
    # is a rare case and NOT_FOUND processing is much faster than normal
    # requests anyway.
    $uri = join('/', @uri[0..$path_info_index]);
    return ($info->{task}, $realm,
	    '/'.join('/', @uri[$path_info_index+1..$#uri]), $orig_uri)
	    if defined($_FROM_URI{$uri})
		    && defined($info = $_FROM_URI{$uri}->[$rti])
			    && $info->{has_path_info};

    # Well, really not found
    $req->throw_die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
	realm_type => $realm->get('type')->get_name,
	orig_uri => $orig_uri,
	uri => $uri,
	message => 'no such URI for this realm'})
}

=for html <a name="setup_facade"></a>

=head2 static setup_facade(string facade, Bivio::Agent::Request req)

Sets up the facade.  We diddle http_host here for lack of
a better place right now.

TODO: Make this general.  For now it will work fine.

=cut

sub setup_facade {
    my($proto, $facade, $req) = @_;
    Bivio::UI::Facade->setup_request($facade, $req);
    $facade = $req->get('facade');
    return if $facade->get('is_default');

    # Not the default facade
    my($http_host) = $req->get(qw(http_host));
    my($uri) = $facade->get('uri');
    $http_host =~ s/^(?:www\.)?/$uri./;
    $req->put(http_host => $http_host);
    return;
}

=for html <a name="task_has_uri"></a>

=head2 task_has_uri(Bivio::Agent::TaskId task_id) : boolean

Does the task have a uri?

=cut

sub task_has_uri {
    my(undef, $task_id) = @_;
    Bivio::Die->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    return defined($_FROM_TASK_ID{$task_id}->{uri}) ? 1 : 0;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
