# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmInvite;
use strict;
$Bivio::Biz::Model::RealmInvite::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmInvite - interface to realm_invite_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmInvite;
    Bivio::Biz::Model::RealmInvite->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmInvite::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmInvite> is the create, read, update,
and delete interface to the C<realm_invite_t> table.

=cut


=head1 CONSTANTS

=cut

=for html <a name="EXPIRE_DAYS"></a>

=head2 EXPIRE_DAYS : int

Number of days for expiry.

=cut

sub EXPIRE_DAYS {
    return 7;
}

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::Auth::Role;
use Bivio::Biz::Model::Email;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::SQL::Constraint;
use Bivio::SQL::ListQuery;
use Bivio::Type::DateTime;
use Bivio::Type::Email;
use Bivio::Type::Integer;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::RealmInviteState;
use Bivio::Type::Text;
use Bivio::Type::PrimaryId;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_COOKIE_FIELD) = Bivio::Agent::HTTP::Cookie->REALM_INVITE_FIELD;
my($_QUERY_FIELD) = 'x';
my($_MIN_PRIMARY_ID) = Bivio::Type::PrimaryId->get_min;
my($_MAX_INTEGER) = Bivio::Type::Integer->get_max;
my($_SEPARATOR) = '!';

=head1 METHODS

=cut

=for html <a name="check_accept"></a>

=head2 static check_accept(Bivio::Agent::Request req)

If there is a pending accept, load and set the I<realm_invite_state>
I<realm_invite_shadow_user> (if set)
on I<req>.  These values will be undef, if not loaded.
Cookie is unmodified.

=cut

sub check_accept {
    my($proto, $req) = @_;

    my($self) = _check_cookie($proto, $req);
    _set_state($self, $req) if ref($self);

    return;
}

=for html <a name="check_accept_after_login"></a>

=head2 static check_accept_after_login(Bivio::Biz::Model::LoginForm login)

B<Only called by L<Bivio::Biz::Model::LoginForm|Bivio::Biz::Model::LoginForm>.>

If there is an outstanding invitation on the request or in the
cookie, do nothing.
Check to see if the auth_user's email matches an outstanding invitation.
If so redirect to the invite task.

=cut

sub check_accept_after_login {
    my($proto, $login) = @_;
    my($req) = $login->get_request;

    # Is there an existing invite on the request?
    my($invite) = $req->unsafe_get('Bivio::Biz::Model::RealmInvite');
    if ($invite) {

	# New User registering via an invite URL
	if ($req->get('Bivio::Biz::Model::CreateUserForm')) {
	    RealmInviteAcceptForm->execute($req, {});
	    $req->client_redirect(Bivio::Agent::TaskId::CLUB_USER_NEW());
	    # DOES NOT RETURN
	}

#TODO: What case is this?
	_trace($invite, ': returning to task') if $_TRACE;
	return;
    }

    # Don't do anything if already unwinding to an invite task
    my($task) = $login->unsafe_get_context('unwind_task');
    if (defined($task) && ($task == Bivio::Agent::TaskId::REALM_INVITE_ACCEPT()
            || $task == Bivio::Agent::TaskId::CLUB_GUEST_2_MEMBER_ACCEPT())) {
	_trace('unwinding to ', $task) if $_TRACE;
	return;
    }

    # Find an invite by the user's email
    my($email) = Bivio::Biz::Model::Email->new($req);
    my($auth_user) = $req->get('auth_user');
    my($auth_user_id) = $auth_user->get('realm_id');
    $invite = Bivio::Biz::Model::RealmInvite->new($req);

    # Find by oldest invitation which matches email
    $email->unauth_load_or_die(realm_id => $auth_user_id);
    my($it) = $invite->unauth_iterate_start('creation_date_time asc',
	    {email => $email->get('email')});

    my($ok) = $invite->iterate_next_and_load($it);
    $invite->iterate_end($it);

    # Try to find by other realm_name@bivio.com email
    unless ($ok) {
	$it = $invite->unauth_iterate_start('creation_date_time asc',
		{email => $auth_user->format_email});
	$ok = $invite->iterate_next_and_load($it);
	$invite->iterate_end($it);
    }
    _trace($invite, ': ok=', $ok) if $_TRACE;

    # No invites?
    return unless $ok;

    # Do not use local format_query, because it includes the auth_code
    # which we want from the user.
    my($query) = $invite->SUPER::format_query();

    # Have an invite figure out what type of invite it is
    my($realm_user_id) = $invite->get('realm_user_id');
    if ($realm_user_id eq $auth_user_id) {
	# Guest 2 Member (needs a realm)
	$req->client_redirect(
		Bivio::Agent::TaskId::CLUB_GUEST_2_MEMBER_ACCEPT(),
		Bivio::Auth::Realm->new($invite->get('realm_id'), $req),
		$query, undef);
	# DOES NOT RETURN
    }

    # Normal invitation
    $req->client_redirect(
	    Bivio::Agent::TaskId::REALM_INVITE_ACCEPT(),
	    undef, $query, undef);
    # DOES NOT RETURN
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{creation_date_time};

    # Save the user who initiated the invite
    $values->{user_id}
	    = $self->get_request->get('auth_user')->get('realm_id')
		    unless defined($values->{user_id});

    return $self->SUPER::create($values);
}

=for html <a name="delete"></a>

=head2 delete()

=head2 static delete(hash load_args) : boolean

Calls SUPER, but first deletes "this" invite cookie if set.

=cut

sub delete {
    my($self) = shift;
    $self->delete_cookie();
    return $self->SUPER::delete(@_);
}

=for html <a name="delete_cookie"></a>

=head2 delete_cookie()

Delete this instance's cookie field. It might be that the user has
an invite and she is, say, editing the invite list for her
club.  Put the cookie field back in this weird case.

=cut

sub delete_cookie {
    my($self) = @_;
    my($cookie) = $self->get_request->get('cookie');
    my($c) = $cookie->delete($_COOKIE_FIELD);

    return unless defined($c);

    # Don't actually delete the cookie if the user was editing the
    # invite list.  User may have only submitted the id, not the auth_code.
    my($id, $ac) = split(' ', $c);
    $cookie->put($_COOKIE_FIELD, $c) if $c ne $self->get('realm_invite_id');
    return;
}

=for html <a name="execute_accept"></a>

=head2 static execute_accept(Bivio::Agent::Request req)

Called as the first part of a realm invite task.  This
may be called if there is a query string iwc we'll load from query.
Otherwise, we'll check the cookie to see if there is an outstanding
invite and load it.

Sets the realm to that of the realm_id of the invite.  Determines
the L<Bivio::Type::RealmInviteState|Bivio::Type::RealmInviteState>
and puts I<realm_invite_shadow_user> and I<realm_invite_state> on request.

=cut

sub execute_accept {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);

    # Did the user just click on the "accept" link
    my($q) = $req->unsafe_get('query');
    if ($req->unsafe_get('query')) {
	my($lq) = Bivio::SQL::ListQuery->unauth_new({%$q},
		$self, $self->internal_get_sql_support);
	my($id) = $lq->unsafe_get('this');

	# User hacked the query?
	$self->die(Bivio::DieCode::CORRUPT_QUERY(),
		'missing or incorrect this') unless $id && $id->[0];

	# If it didn't load, just like cookie not found
	$self->die(Bivio::DieCode::NOT_FOUND(),
		'invite not found in db from query')
		unless $self->unauth_load(realm_invite_id => $id->[0]);

	# Compare actual and expected
	my($actual) = $lq->unsafe_get($_QUERY_FIELD) || '';
	my($expected) = $self->get_auth_code();
	_trace('actual=', $actual, '; expected=', $expected) if $_TRACE;
	if (defined($actual) && length($actual)) {
	    $self->die(Bivio::DieCode::NOT_FOUND(),
		    {actual => $actual, expected => $expected,
			message => 'auth_code field mismatch'})
		    unless $actual eq $expected;
	    $req->put(realm_invite_auth_code => $actual);
	}

	# Loaded ok, so set in the cookie with $actual, if it was passed in
	$req->get('cookie')->put($_COOKIE_FIELD,
		$self->get('realm_invite_id').$_SEPARATOR.$actual);
    }
    else {
	# If there is a valid cookie, try to load it
	$self = _check_cookie($proto, $req);
#TODO: Make these two cases distinct?
	$req->die(Bivio::DieCode::NOT_FOUND(),
		entity => $self, model => $proto) unless $self;
	$req->die(Bivio::DieCode::NOT_FOUND(),
		entity => $self, model => $proto) unless ref($self);
    }

    _set_state($self, $req);
    return;
}

=for html <a name="format_query"></a>

=head2 format_query() : string

Formats the query string with I<this> and I<auth_code>.

=cut

sub format_query {
    my($self) = @_;
    return $self->SUPER::format_query().'&'.$_QUERY_FIELD
	    .'='.$self->get_auth_code;
}

=for html <a name="get_auth_code"></a>

=head2 get_auth_code() : Bivio::Type::Integer

=head2 static get_auth_code(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Returns the authorization code for this invite.

=cut

sub get_auth_code {
    my($self, $m, $p) = @_;
    $p ||= '';
    $m ||= $self;

    # RealmInviteList assumes that only "get" is called.
    my($id, $realm_id, $date_time) = $m->get(
	    $p.'realm_invite_id', $p.'realm_id', $p.'creation_date_time');

    # None of this is critical except that the algorithm can't change
    # without changing the version.  We don't really take advantage
    # of the internals.
    $id = int($id/$_MIN_PRIMARY_ID % $_MAX_INTEGER);
    $realm_id = int($realm_id/$_MIN_PRIMARY_ID % $_MAX_INTEGER);
    my($date, $time) = split(/\s+/, $date_time);

    # XOR all these values
    return $id ^ $realm_id ^ $date ^ $time;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_invite_t',
	columns => {
            realm_invite_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
	    # Will be null if just a "guest"
	    realm_user_id => ['PrimaryId', 'NONE'],
            email => ['Email', 'NOT_NULL'],
            role => ['Bivio::Auth::Role', 'NOT_ZERO_ENUM'],
	    honorific => ['Honorific', 'NOT_ZERO_ENUM'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
	    # unique(realm_id, email)
        },
	auth_id => [qw(realm_id RealmOwner_1.realm_id)],
	other => [
	    [qw(user_id RealmOwner_2.realm_id)],
	],
    };
}

=for html <a name="redirect_if_accept"></a>

=head2 static redirect_if_accept(Bivio::Agent::Request req)

Redirects to accept task if there is an accept pending.
L<check_accept|"check_accept"> must be called first.

=cut

sub redirect_if_accept {
    my(undef, $req) = @_;
    $req->client_redirect(Bivio::Agent::TaskId::REALM_INVITE_ACCEPT())
	    if $req->unsafe_get('Bivio::Biz::Model::RealmInvite');
    return;
}

#=PRIVATE METHODS

# _check_cookie(any proto, Bivio::Agent::Request req) : Bivio::Biz::Model::RealmInvite
#
# Returns the realm invite model if can be loaded from the cookie.
# Returns the cookie string if the realm invite couldn't be loaded,
# but there was a cookie.
#
sub _check_cookie {
    my($proto, $req) = @_;

    # Coming in from another class.  Can we load from the cookie?
    my($cookie) = $req->get('cookie');
    my($c) = $cookie->unsafe_get($_COOKIE_FIELD);
    # Nope, return; else fall through to normal business logic
    return undef unless $c;

    my($id, $ac) = split(/$_SEPARATOR/o, $c);

    my($self) = $proto->new($req);
    if ($self->unauth_load(realm_invite_id => $id)) {
#TODO: DELETE THIS LINE after 6/15/2000.
	$ac = $self->get_auth_code() unless $c =~ /$_SEPARATOR/o;

	_trace('actual=', $ac, '; expected=', $self->get_auth_code) if $_TRACE;
	# If the auth_code was in the cookie, set it on the request.
	if (defined($ac) && $ac eq $self->get_auth_code()) {
	    $req->put(realm_invite_auth_code => $ac);
	}
	return $self;
    }
    _trace($c, ': not found, deleting cookie') if $_TRACE;
    $cookie->delete($_COOKIE_FIELD);
    return $c;
}

# _set_state(Bivio::Biz::Model::RealmInvite self, Bivio::Agent::Request req)
#
# Sets the realm_invite_state $req.
#
sub _set_state {
    my($self, $req) = @_;

    # Compute the RealmInviteState
    my($user) = $req->unsafe_get('auth_user');
    my($invited_user) = Bivio::Biz::Model::RealmOwner->new($req);
    $invited_user = undef
	    unless $invited_user->unauth_load_by_email($self->get('email'));
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    my($state) = $user
	    ? ($realm_user->unauth_load(user_id => $user->get('realm_id'),
		    realm_id => $self->get('realm_id'))
		    ? 'AUTH_USER_IS_REALM_USER'
			    : $invited_user && $invited_user->get('realm_id')
				    eq $user->get('realm_id')
				    ? 'AUTH_USER_MATCHES_EMAIL' : 'AUTH_USER')
	    : $invited_user ? 'EMAIL_MATCHES_USER' : 'NO_USER';

    my($shadow);
    if ($self->get('realm_user_id')) {
	$shadow = Bivio::Biz::Model::RealmOwner->new($req);
	$shadow->unauth_load_or_die(realm_id => $self->get('realm_user_id'),
		realm_type => Bivio::Auth::RealmType::USER());
    }

    $req->put(
	    realm_invite_state => Bivio::Type::RealmInviteState->$state(),
	    realm_invite_shadow_user => $shadow,
	   );
    _trace($self->get('realm_invite_id'), ': state=', $state) if $_TRACE;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
