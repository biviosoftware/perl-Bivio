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
# is a tuple: [task_id, uri]
my(%_FROM_URI);
# Key is task_id, value is alias to _FROM_URI value (for realm)
my(%_FROM_TASK_ID);
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

=head2 static format(Bivio::Agent::TaskId task_id, Bivio::Auth::Realm realm, Bivio::Agent::Request req, boolean no_context) : string

Transforms I<task_id> and I<realm> (if needed) into a URI.

=cut

sub format {
    my(undef, $task_id, $realm, $req, $no_context) = @_;
    Bivio::IO::Alert->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    my($uri) = $_FROM_TASK_ID{$task_id}->[1];
    Bivio::IO::Alert->die($task_id, ': task has no uri')
	    unless defined($uri);
#TODO: Add in the form context with \& at the end which turns into nothing
# if no context added.
    # URI contains a lone
    if ($uri =~ /%/) {
	# If the realm doesn't have an owner, there's a bug somewhere
	my($ro) = $realm->format_uri;
	# Replace everything leading up to the % with the uri prefix
	$uri =~ s/.*%/$ro/g;
    }
    $uri = '/'.$uri unless $uri =~ /^\//;

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

Initializes %_FROM_URI using simplified syntax to allow easier configuration.

=cut

sub initialize {
    $_INITIALIZED && return;
    my($cfg) = Bivio::Agent::TaskId->get_cfg_list;
    $_GENERAL = Bivio::Auth::Realm::General->new;
    my($_PROXY_PREFIX) = Bivio::Auth::Realm::Proxy::FIRST_URI_COMPONENT().'/%';
    map {
	my($task_id_name, $realm_type_name, $uri_list) = @{$_}[0,2,4];
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
	# Make the first one the alias
	my($got_one) = 0;
	foreach $uri (reverse(split(/:/, $uri_list))) {
	    $got_one++;
	    if ($uri eq '!') {
		# Special case: empty uri
		$uri = undef;
	    }
	    else {
		# Is the URI valid
		if (!$is_general) {
		    if ($realm_type_name eq 'PROXY') {
			die("$task_id_name: $uri: must begin with 'pub/%'")
				unless $uri =~ m!^$_PROXY_PREFIX(?:\/|$)!o;
		    }
		    else {
			die("$task_id_name: $uri: must begin with '%'")
				unless $uri =~ m!^%(?:\/|$)!;
		    }
		}

		# Save the URI in the map
		if ($_FROM_URI{$uri}) {
		    die("$task_id_name: $uri $realm_type_name: uri already"
			    .' mapped to ',
			    $_FROM_URI{$uri}->[$rti]->[0]->get_name)
			    if $_FROM_URI{$uri}->[$rti];
		}
		else {
		    $_FROM_URI{$uri} = [];
		}
		$_FROM_URI{$uri}->[$rti] = [$task_id, $uri];
	    }
	    $_FROM_TASK_ID{$task_id} = [$task_id, $uri];
	}
	die("$task_id_name: must have at least on uri, use '!' for blank")
		unless $got_one;
    } @$cfg;
    if (defined($_DOCUMENT_ROOT)) {
	$_DOCUMENT_TASK
		= $_FROM_TASK_ID{Bivio::Agent::TaskId::HTTP_DOCUMENT()};
	die('HTTP_DOCUMENT: task must be configured if document_root set')
	    unless $_DOCUMENT_TASK;
    }
    $_INITIALIZED = 1;
    return;
}

=for html <a name="parse"></a>

=head2 static parse(string uri, Bivio::Agent::Request req) : array

Returns I<task_id> and I<auth_realm> for I<uri>.

=cut

sub parse {
    my(undef, $req, $uri) = @_;
    my($orig_uri) = $uri;
    $uri =~ s!^/+!!g;
    # Percent is a special character
    my(@uri) = map {
	$req->die(Bivio::DieCode::NOT_FOUND,
		{entity => $orig_uri, message => 'contains percent'})
		if $_ eq '%';
	$_
    } split(/\/+/, $uri);
    $uri = join('/', @uri);
    # General realm is direct map, no underscores
    return ($_FROM_URI{$uri}->[$_GENERAL_INT]->[0], $_GENERAL)
	    if defined($_FROM_URI{$uri}->[$_GENERAL_INT]);

    # If first uri doesn't match a RealmName, can't be one.
    if (!length($uri) || $uri[0] !~ /^\w{3,}$/) {
	# Not a realm, but is it a document and it is found?
	return ($_DOCUMENT_TASK->[0], $_GENERAL)
		if defined($_DOCUMENT_ROOT) && -e ($_DOCUMENT_ROOT . $uri);

	$req->die(Bivio::DieCode::NOT_FOUND, {uri => $orig_uri,
	    entity => $_DOCUMENT_ROOT.$uri});
    }

    # Try to find the uri with the realm replaced by '%'
    # Replace realm with underscore.  This is ugly, but good enough for now.
    my($realm);
    if ($uri[0] eq Bivio::Auth::Realm::Proxy::FIRST_URI_COMPONENT()) {
	#
	# Proxy Realm
	#
	# RJN: This is experimental.  I'm not sure if this is the right
	# 	   approach, because all Celebrity realms may not contain the
	# 	   same URIs.
	# Be friendly, by downcasing
	my($name) = lc($uri[1]);
	$uri[1] = '%';

	# Blows up if not found.
	$realm = Bivio::Auth::Realm::Proxy->from_name($name);
    }
    elsif (defined($_FROM_URI{$uri})) {
	#
	# Ordinary Realm
	#
	# Be friendly, by downcasing
	my($name) = lc($uri[0]);
	$uri[0] = '%';

	# Is this a valid, authorized realm with a task for this uri?
	my($o) = Bivio::Biz::Model::RealmOwner->new($req);
	$req->die(Bivio::DieCode::NOT_FOUND,
		{entity => $name, uri => $orig_uri,
		    class => 'Bivio::Auth::Realm'})
		unless $o->unauth_load(name => $name);
	$realm = Bivio::Auth::Realm->new($o);
    }
    else {
	$req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri});
    }

    # Found the realm, now try to find the URI
    $uri = join('/', @uri);
    my($rti) = $realm->get('type')->as_int;
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
	realm_type => $realm->get('type')->get_name})
	    unless defined($_FROM_URI{$uri}->[$rti]);
    return ($_FROM_URI{$uri}->[$rti]->[0], $realm);
}

=for html <a name="task_has_uri"></a>

=head2 task_has_uri(Bivio::Agent::TaskId task_id) : boolean

Does the task have a uri?

=cut

sub task_has_uri {
    my(undef, $task_id) = @_;
    Bivio::IO::Alert->die($task_id, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    return defined($_FROM_TASK_ID{$task_id}->[1]) ? 1 : 0;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
