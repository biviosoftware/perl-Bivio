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
use Bivio::Auth::Realm::AnyMember;
use Bivio::Auth::Realm::AnyUser;
use Bivio::Auth::Realm::Club;
use Bivio::Auth::Realm::Public;
use Bivio::Auth::Realm::User;
use Bivio::Auth::Realm;
use Bivio::Biz::PropertyModel::RealmOwner;
use Bivio::DieCode;

#=VARIABLES
my($_INITIALIZED) = 0;
my(%_FROM_URI);
my(%_FROM_TASK_ID);

=head1 METHODS

=cut

=for html <a name="format"></a>

=head2 static format(Bivio::Agent::TaskId task_id, Bivio::Auth::Realm realm) : string

Transforms I<task_id> and I<realm> (if needed) into a URI.

=cut

sub format {
    my(undef, $task_id, $realm) = @_;
    die($task_id->as_string, ': no such task')
	    unless $_FROM_TASK_ID{$task_id};
    my($uri) = $_FROM_TASK_ID{$task_id}->[2];
    # If the realm doesn't have an owner, then a bug and will crash.
    $uri =~ s/_/$realm->get('owner_name')/eg;
    return '/' . $uri;
}

=for html <a name="initialize"></a>

=head2 static initialize()

Initializes %_FROM_URI using simplified syntax to allow easier configuration.

=cut

sub initialize {
    $_INITIALIZED && return;
    my(%static) = (
	PUBLIC => Bivio::Auth::Realm::Public->new(),
	ANY_USER => Bivio::Auth::Realm::AnyUser->new(),
	ANY_MEMBER => Bivio::Auth::Realm::AnyMember->new(),
    );
    my($cfg) = Bivio::Agent::TaskId->get_cfg_list;
    map {
	my($task_id_name, $realm_type, $uri_list) = @{$_}[0,2,4];
	my($task_id) = Bivio::Agent::TaskId->$task_id_name();
	# Test for all the realms we understand, explicitly.
	my($realm) = $static{$realm_type};
	unless ($realm) {
	    die("$realm_type: unknown realm type")
		    unless $realm_type =~ /^(CLUB|USER)$/;
	    $realm = 'Bivio::Auth::Realm::' . ucfirst(lc($realm_type));
	}
	my($uri);
	foreach $uri (split(/:/, $uri_list)) {
	    die("$uri: uri already mapped") if $_FROM_URI{$uri};
	    #TODO: Make a better mapping algorithm
	        $_FROM_TASK_ID{$task_id} = $_FROM_URI{$uri}
			= [$realm, $task_id, $uri];
	}
    } @$cfg;
    $_INITIALIZED = 1;
    return;
}

=for html <a name="parse"></a>

=head2 static parse(string uri, Bivio::Agent::Request req) : (Bivio::Auth::Realm, Bivio::Agent::TaskId)

Parses I<uri> for the realm and task_id.

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
#TODO: Need to be able to map '/'
    # Realm without an owner
    return @{$_FROM_URI{$uri}}[0,1] if defined($_FROM_URI{$uri});
    die("$uri: / not found") unless int(@uri);
    my($name) = shift(@uri);
    # Replace realm with underscore.  This is ugly, but good enough for now.
    $uri = join('/', '_', @uri);
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => $orig_uri})
	    unless defined($_FROM_URI{$uri});
    my($class, $realm);
#TODO: Only search the appropriate realm.  Need to do something about
#      shared realm uris.
    my($o) = Bivio::Biz::PropertyModel::RealmOwner->new($req);
    $req->die(Bivio::DieCode::NOT_FOUND,
	    {entity => $name, uri => $orig_uri, class => 'Bivio::Auth::Realm'})
	    unless $o->unauth_load(name => $name);
    $realm = Bivio::Auth::Realm->new($o);
    my($realm_class, $task_id) = @{$_FROM_URI{$uri}};
    $req->die(Bivio::DieCode::NOT_FOUND,
	    {entity => $orig_uri, realm_class => $realm_class})
	    unless $realm_class eq ref($realm);
    return ($realm, $task_id);
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
