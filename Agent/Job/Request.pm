# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Job::Request;
use strict;
$Bivio::Agent::Job::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Job::Request - Bivio::Agent::Request wrapper for jobs

=head1 SYNOPSIS

    use Bivio::Agent::Job::Request;
    Bivio::Agent::Job::Request->new($params);

=cut

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::Job::Request::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::Job::Request> sets the params appropriately.  It
loads a new auth_realm every time.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Type::DateTime;
use Bivio::HTML;
use Bivio::Agent::Reply;
use Bivio::Auth::Realm::General;
use Bivio::Auth::Realm;
use Bivio::Type::UserAgent;

#=VARIABLES
my($_GENERAL);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref params) : Bivio::Agent::Job::Request

Creates a Request from the queued I<params>.

=cut

sub new {
    my($proto, $params) = @_;
    my($start_time) = Bivio::Type::DateTime->gettimeofday();
#TODO: Need to handle Facades!
    my($self) = Bivio::Agent::Request::internal_new($proto, {
	# We set the params here, because we want to override values
	%$params,
	start_time => $start_time,
	form => undef,
	query => undef,
	# Needed by Task->execute, but not used here
	reply => Bivio::Agent::Reply->new(),
    });
    Bivio::Type::UserAgent->execute_job($self);

    # Realm
    my($realm);
    if ($params->{auth_id}) {
	$realm = Bivio::Auth::Realm->new($params->{auth_id}, $self);
    }
    else {
	$_GENERAL = Bivio::Auth::Realm::General->new unless $_GENERAL;
	$realm = $_GENERAL;
    }
    $self->internal_set_current();

    # User
    my($auth_user);
    if ($params->{auth_user_id}) {
	$auth_user = Bivio::Biz::Model::RealmOwner->new($self);
	$auth_user->unauth_load(realm_id => $params->{auth_user_id})
		|| Bivio::Die->die('unable to load user=',
			$params->{auth_user_id});
    }
    $self->internal_initialize($realm, $auth_user);
    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 SEE ALSO

Bivio::Job::Incoming

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
