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
use Bivio::IO::Config;
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::Club;
use Bivio::Auth::Realm::General;
use Bivio::Auth::Realm::User;
use Bivio::Auth::Realm;
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::RealmOwner;
use Bivio::DieCode;
use Carp ();

#=VARIABLES
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

=head2 static format(Bivio::Agent::TaskId task_id, Bivio::Auth::Realm realm) : string

Transforms I<task_id> and I<realm> (if needed) into a URI.

=cut

sub format {
    my(undef, $task_id, $realm) = @_;
    Carp::croak($task_id->as_string, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    my($uri) = $_FROM_TASK_ID{$task_id}->[1];
#TODO: Only can have realm owner at front of uri.
    if ($uri =~ /^_/) {
	# If the realm doesn't have an owner, there's a bug somewhere
	my($ro) = $realm->get('owner_name');
	$uri =~ s/^_/$ro/g;
    }
    return $uri =~ /^\// ? $uri : '/'.$uri;
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
    map {
	my($task_id_name, $realm_type_name, $uri_list) = @{$_}[0,2,4];
	my($task_id) = Bivio::Agent::TaskId->$task_id_name();
	# Test for all the realms we understand, explicitly.
	my($is_general) = $realm_type_name eq 'GENERAL';
	my($realm);
	if ($is_general) {
	    $realm = $_GENERAL;
	}
	elsif ($realm_type_name =~ /^(CLUB|USER)$/) {
	    $realm = 'Bivio::Auth::Realm::' . ucfirst(lc($realm_type_name));
	}
	else {
	    die("$realm_type_name: unknown realm type");
	}
	my($rti) = $realm->get_type->as_int;
	my($uri);
	foreach $uri (split(/:/, $uri_list)) {
	    die("$uri: must begin with '_'")
		    unless $is_general || $uri =~ /^_(\/|$)/;
	    if ($_FROM_URI{$uri}) {
		die("$uri: uri already mapped") if $_FROM_URI{$uri}->[$rti];
		$_FROM_URI{$uri} = [];
	    }
	    $_FROM_TASK_ID{$task_id} = $_FROM_URI{$uri}->[$rti]
		    = [$task_id, $uri];
	}
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
#TODO: Is this lc a dubious practice?  It will help clubs/users
#      which like their names mixed case.
    my($orig_uri) = $uri;
    $uri = lc($uri);
    $uri =~ s!^/+!!g;
    # Underscore is a special character
    my(@uri) = map {
	$req->die(Bivio::DieCode::NOT_FOUND,
		{entity => $orig_uri, message => 'contains underscore'})
		if $_ eq '_';
	$_
    } split(/\/+/, $uri);
    $uri = join('/', @uri);
    # General realm is direct map, no underscores
    return ($_FROM_URI{$uri}->[$_GENERAL_INT]->[0], $_GENERAL)
	    if defined($_FROM_URI{$uri}->[$_GENERAL_INT]);

    # If document_root is set, look for the file directly.  If found,
    # go to HTTP_DOCUMENT task.
    return ($_DOCUMENT_TASK->[0], $_GENERAL)
	    if defined($_DOCUMENT_ROOT) && -e ($_DOCUMENT_ROOT . $uri);

    # If '/', then always not found
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri})
	    unless int(@uri);

    # Try to find the uri with the realm replaced by '_'.
    my($name) = shift(@uri);
    # Replace realm with underscore.  This is ugly, but good enough for now.
    $uri = join('/', '_', @uri);
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri})
	    unless defined($_FROM_URI{$uri});

    # Is this a valid, authorized realm with a task for this uri?
    my($o) = Bivio::Biz::Model::RealmOwner->new($req);
    $req->die(Bivio::DieCode::NOT_FOUND,
	    {entity => $name, uri => $orig_uri, class => 'Bivio::Auth::Realm'})
	    unless $o->unauth_load(name => $name);
    my($realm) = Bivio::Auth::Realm->new($o);
    my($rti) = $realm->get_type->as_int;
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri,
            realm_type => $realm->get_type->get_name})
	    unless defined($_FROM_URI{$uri}->[$rti]);
    return ($_FROM_URI{$uri}->[$rti]->[0], $realm);
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
