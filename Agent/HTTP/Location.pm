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
use Bivio::Biz::PropertyModel::Club;
use Bivio::Biz::PropertyModel::User;

#=VARIABLES
my(%_FROM_URI);
my(%_FROM_TASK_ID);
# Is empty after initialization.
# Last task_id in list is mapped in $_FROM_TASK_ID
my(@_MAP_INITIALIZER) = qw(
    PUBLIC 	club/setup 		SETUP_INTRO
    _		user/new		SETUP_USER_EDIT
    _		user/created		SETUP_USER_CREATE
    ANY_USER    club/new	        SETUP_CLUB_EDIT
    _		club/created	        SETUP_CLUB_CREATE
    CLUB        _                       CLUB_MESSAGE_LIST
    _           _/messages		CLUB_MESSAGE_LIST
    _           _/messages/detail	CLUB_MESSAGE_DETAIL
    _           _/members		CLUB_MEMBER_LIST
    _           _/members/new		CLUB_MEMBER_ADD_EDIT
    _           _/members/added		CLUB_MEMBER_ADD
);

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
    @_MAP_INITIALIZER || return;
    die('@_MAP_INITIALIZER size must be a multiple of 3')
	    if int(@_MAP_INITIALIZER) % 3;
    my(%static) = (
	    PUBLIC => Bivio::Auth::Realm::Public->new(),
	    ANY_USER => Bivio::Auth::Realm::AnyUser->new(),
	    ANY_MEMBER => Bivio::Auth::Realm::AnyMember->new(),
	   );
    local($_);
    my($realm, $uri, $task_id_name);
    while (@_MAP_INITIALIZER) {
	my($new_realm) = shift(@_MAP_INITIALIZER);
	($uri, $task_id_name)
		= (shift(@_MAP_INITIALIZER), shift(@_MAP_INITIALIZER));
	my($task_id) = Bivio::Agent::TaskId->$task_id_name();
	# Test for all the realms we understand, explicitly.
	unless ($new_realm eq '_' || ($realm = $static{$new_realm})) {
	    die("$new_realm: unknown realm type")
		    unless $new_realm =~ /^(CLUB|USER)$/;
	    $realm = 'Bivio::Auth::Realm::' . ucfirst(lc($new_realm));
	}
	die("$uri: uri already mapped") if defined($_FROM_URI{$uri});
#TODO: Make a better mapping algorithm
	$_FROM_TASK_ID{$task_id} = $_FROM_URI{$uri} = [$realm, $task_id, $uri];
    }
    undef(@_MAP_INITIALIZER);
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
    $uri = lc($uri);
    $uri =~ s!^/+!!g;
    # Underscore is a special character
    my(@uri) = map {
	die("$uri: uri contains underscore") if $_ eq '_';
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
    die("$uri: uri within realm not found") unless defined($_FROM_URI{$uri});
    my($class, $realm);
    foreach $class ('Club', 'User') {
	my($c) = "Bivio::Biz::PropertyModel::$class";
	my($o) = $c->new($req);
	$o->unauth_load(name => $name) || next;
	$c = "Bivio::Auth::Realm::$class";
	$realm = $c->new($o);
	last;
    }
    die("$uri: realm not found") unless $realm;
    my($realm_class, $task_id) = @{$_FROM_URI{$uri}};
    die("$uri: uri not within realm") unless $realm_class eq ref($realm);
    return ($realm, $task_id);
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
