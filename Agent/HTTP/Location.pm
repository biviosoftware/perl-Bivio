# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Location;
use strict;
$Bivio::Agent::HTTP::Location::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Location - provides URL to realm/task_id mapping

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Location;
    Bivio::Agent::HTTP::Location->parse($uri);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::HTTP::Location::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Location> maps a URI to a
L<Bivio::Auth::Realm|Bivio::Auth::Realm> and a
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

When adding new syntax to the configuration table, default to a restrictive
set.  We don't know the path this module will be taking over the years,
so we should try to be as simple as possible until we know otherwise.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::General;
use Bivio::Auth::Realm;
use Bivio::Auth::Realm::Proxy;
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::RealmOwner;
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
Bivio::IO::Config->register({
    document_root => undef,
});

=head1 METHODS

=cut

=for html <a name="format"></a>

=head2 static format(Bivio::Agent::TaskId task_id, Bivio::Auth::Realm realm, Bivio::Agent::Request req, boolean no_context, string path_info) : string

Transforms I<task_id> and I<realm> (if needed) into a URI.

B<path_info is not escaped>

=cut

sub format {
    my(undef, $task_id, $realm, $req, $no_context, $path_info) = @_;
    Bivio::IO::Alert->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    my($info) = $_FROM_TASK_ID{$task_id};
    my($uri) = $info->{uri};
    Bivio::IO::Alert->die($task_id, ': task has no uri')
	    unless defined($uri);

#TODO: Add in the form context with \& at the end which turns into nothing
# if no context added.
    # URI contains a lone
    if ($uri =~ /\?/) {
	# If the realm doesn't have an owner, there's a bug somewhere
	my($ro) = $realm->format_uri;
	# Replace everything leading up to the ? with the uri prefix
	$uri =~ s/.*\?/$ro/g;
    }
    $uri = '/'.$uri unless $uri =~ /^\//;

    # Append path_info, if necessary.  Note that we don't check for
    # "defined", because path_info is returned as '' from "parse".
    # We do this so we can handle safely in various bits of code.
    # path_info must begin with a '/' if it is set.
    if ($info->{has_path_info}) {
	if ($path_info) {
	    Bivio::IO::Alert->die($task_id, '(', $uri, '): missing path_info')
			unless $path_info;
	    Bivio::IO::Alert->die($task_id, '(', $uri,
		    '): path_info must begin with slash (', $path_info, ')')
			unless $path_info =~ /^\//;
	    $uri .= Bivio::Util::escape_uri($path_info);
	}
    }
    else {
#TODO: This assertion check doesn't work
#	Bivio::IO::Alert->die($task_id, '(', $uri,
#		'): does not require path_info (', $path_info, ')')
#		    if $path_info;
    }

#TODO: Hack.  Recursion in FormModel otherwise
    return $uri if $no_context;

#TODO: Tightly coupled with UI::HTML::Widget::Form.
    my($rc) = Bivio::Agent::Task->get_by_id($task_id)->get('require_context');
    $uri .= '?'.Bivio::Biz::FormModel->format_context_as_query($req) if $rc;
    return $uri;
}

=for html <a name="get_document_root"></a>

=head2 get_document_root() : string

Returns the document root.

=cut

sub get_document_root {
    return $_DOCUMENT_ROOT;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item document_root : string [undef]

If defined, URIs not found by the normal mechanism will be sought
for in this directory.  The realm is specified by
C<HTTP_DOCUMENT> task.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_DOCUMENT_ROOT = $cfg->{document_root};
    return unless defined($_DOCUMENT_ROOT);
    die("$_DOCUMENT_ROOT: not a directory") unless -d $_DOCUMENT_ROOT;
    $_DOCUMENT_ROOT =~ s!([^/])$!$1/!;
    return;
}

=for html <a name="initialize"></a>

=head2 static initialize()

Initialize from syntax as defined in TaskId.  We take special care to
enforce all the syntax rules at compile time.

=cut

sub initialize {
    $_INITIALIZED && return;
    my($cfg) = Bivio::Agent::TaskId->get_cfg_list;
    $_GENERAL = Bivio::Auth::Realm::General->new;
    my($_PROXY_PREFIX) = Bivio::Auth::Realm::Proxy::FIRST_URI_COMPONENT()
	    .'/\?';
    my(%path_info_uri);
    foreach my $c (@$cfg) {
	my($task_id_name, $realm_type_name, $uri_list) = @{$c}[0,2,4];
	my($task_id) = Bivio::Agent::TaskId->$task_id_name();

#TODO: Shouldn't know that GENERAL is a special realm(?)
	# Test for all the realms we understand, explicitly.
	my($is_general) = $realm_type_name eq 'GENERAL';
	my($realm);
	if ($is_general) {
	    $realm = $_GENERAL;
	}

#TODO: Shouldn't have to do this mapping here.  Should be in RealmType.
	elsif ($realm_type_name =~ /^(CLUB|USER|PROXY)$/) {
	    $realm = 'Bivio::Auth::Realm::' . ucfirst(lc($realm_type_name));
	}
	else {
	    die("$task_id_name: $realm_type_name: unknown realm type");
	}

	my($rti) = $realm->get_type->as_int;
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
		# Delete dup slashes and leading / (except DOC ROOT task)
		$uri =~ s/\/{2,}/\//g;
		$uri =~ s/^\/(.)/$1/g;

		# Is this a path_info uri?  We remove the trailing /*, because
		# we want to allow for "empty" path info
		$has_path_info = $uri =~ s/\/\*$//;
		die("$task_id_name: uri must not be /*") unless $uri;

		# Is the URI valid?
		if ($is_general) {
		    die("$task_id_name: path_info not allowed on GENERAL")
			    if $has_path_info;
		}
		else {
		    # URI with realm_owner
		    my($path_info_count) = undef;
		    if ($realm_type_name eq 'PROXY') {
			die("$task_id_name: $uri: must begin with "
				."'$_PROXY_PREFIX'")
				unless $uri =~ m!^$_PROXY_PREFIX(?:\/(.*)|$)!o;
			$path_info_count = 3;
		    }
		    else {
			die("$task_id_name: $uri: must begin with '?'")
				unless $uri =~ m!^\?(?:\/|$)!;
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
		has_path_info => $has_path_info ? 1 : 0,
	    };
	    $_FROM_URI{$uri}->[$rti] = $info if defined($uri);
	    $_FROM_TASK_ID{$task_id} = $info;
	    $path_info_uri{$uri}++ if $has_path_info;
	}
	die("$task_id_name: must have at least on uri, use '!' for blank")
		unless $got_one;
    }

    # Make sure HTTP_DOCUMENT is defined if $_DOCUMENT_ROOT is defined
    if (defined($_DOCUMENT_ROOT)) {
	$_DOCUMENT_TASK
		= $_FROM_TASK_ID{Bivio::Agent::TaskId::HTTP_DOCUMENT()}
			->{task};
	die('HTTP_DOCUMENT: task must be configured if document_root set')
	    unless $_DOCUMENT_TASK;
    }

    # Make sure all URIs don't collide with path_info uris
    foreach my $piu (keys(%path_info_uri)) {
	foreach my $uri (keys(%_FROM_URI)) {
	    die("URI ($uri) collides with path_info uri ($piu)")
		    if $uri =~ m!\Q$piu/!;
	}
    }

    $_INITIALIZED = 1;
    return;
}

=for html <a name="parse"></a>

=head2 static parse(string uri, Bivio::Agent::Request req) : array

Returns I<task_id>, I<auth_realm>, and I<path_info> for I<uri>.

Note that the I<path_info> is left on the URI.

=cut

sub parse {
    my(undef, $req, $uri) = @_;
    my($orig_uri) = $uri;
    $uri =~ s!^/+!!g;
    # Percent is a special character
    my(@uri) = map {
	$req->die(Bivio::DieCode::NOT_FOUND,
		{entity => $orig_uri, message => 'contains special char'})
		if $_ eq '?';
	$_;
    } split(/\/+/, $uri);

    $uri = join('/', @uri);

    # General realm is direct map, no placeholders are path_info
    return ($_FROM_URI{$uri}->[$_GENERAL_INT]->{task}, $_GENERAL, '')
	    if defined($_FROM_URI{$uri}->[$_GENERAL_INT]);

    # If first uri doesn't match a RealmName, can't be one.
    if (!length($uri) || $uri[0] !~ /^\w{3,}$/) {
	# Not a realm, but is it a document and is it found?
	if (defined($_DOCUMENT_ROOT) && -e ($_DOCUMENT_ROOT . $uri)) {
#TODO: Could optimize further and simply return the file here.

	    # OPTIMIZATION: We know the DOCUMENT_TASK does not need
	    # a user.  It is visible to all users.  Therefore, we avoid
	    # a user lookup here which is a database hit.
	    $req->put(user_id => undef);

	    return ($_DOCUMENT_TASK, $_GENERAL, $uri, '');
	}

	# Not found
	$req->die(Bivio::DieCode::NOT_FOUND, {uri => $orig_uri,
	    entity => $_DOCUMENT_ROOT.$uri,
	    message => 'no such document'});
    }

    # Try to find the uri with the realm replaced by '?'
    # Replace realm with underscore.  This is ugly, but good enough for now.
    my($realm);
    # Up to which component is checked for path_info URI
    my($path_info_index) = undef;
    if ($uri[0] eq Bivio::Auth::Realm::Proxy::FIRST_URI_COMPONENT()) {
	#
	# Proxy Realm
	#
	# RJN: This is experimental.  I'm not sure if this is the right
	# 	   approach, because all Celebrity realms may not contain the
	# 	   same URIs.
	# Be friendly, by downcasing
	my($name) = lc($uri[1]);
	$uri[1] = '?';

	# Blows up if not found.
	$realm = Bivio::Auth::Realm::Proxy->from_name($name);

	# Component after realm name must identify path_info URI
	$path_info_index = 2;
    }
    else {
	#
	# Ordinary Realm
	#
	# Be friendly, by downcasing
	my($name) = lc($uri[0]);
	$uri[0] = '?';

	# Is this a valid, authorized realm with a task for this uri?
	my($o) = Bivio::Biz::Model::RealmOwner->new($req);
	$req->die(Bivio::DieCode::NOT_FOUND,
		{entity => $name, uri => $orig_uri,
		    class => 'Bivio::Auth::Realm',
		    message => 'no such realm'})
		unless $o->unauth_load(name => $name);
	$realm = Bivio::Auth::Realm->new($o);
	# Component after realm name must identify path_info URI
	$path_info_index = 1;
    }

    # Found the realm, now try to find the URI (without checking path_info)
    $uri = join('/', @uri);
    my($rti) = $realm->get('type')->as_int;
    # No path info?
    return ($_FROM_URI{$uri}->[$rti]->{task}, $realm, '')
	    if defined($_FROM_URI{$uri}) && defined($_FROM_URI{$uri}->[$rti]);

    # Is this a path_info URI?  Note this may seem a bit "slow", but it
    # is a rare case and NOT_FOUND processing is much faster than normal
    # requests anyway.
    $uri = join('/', @uri[0..$path_info_index]);
    return ($_FROM_URI{$uri}->[$rti]->{task}, $realm,
	    '/'.join('/', @uri[$path_info_index+1..$#uri]))
	    if defined($_FROM_URI{$uri}) && defined($_FROM_URI{$uri}->[$rti]);

    # Well, really not found
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
	realm_type => $realm->get('type')->get_name,
	orig_uri => $orig_uri,
	uri => $uri,
	message => 'no such URI for this realm'})
}

=for html <a name="task_has_uri"></a>

=head2 task_has_uri(Bivio::Agent::TaskId task_id) : boolean

Does the task have a uri?

=cut

sub task_has_uri {
    my(undef, $task_id) = @_;
    Bivio::IO::Alert->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    return defined($_FROM_TASK_ID{$task_id}->{uri}) ? 1 : 0;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
