# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::LoginForm;
use strict;
$Bivio::PetShop::Model::LoginForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::LoginForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::LoginForm - authenticates user via form

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::LoginForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::LoginForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::PetShop::Model::LoginForm> is used to login which changes the
cookie.  Modules which "login" users should call <tt>execute</tt>
with the new realm_owner.

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::RealmOwner;
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::TypeError;
use Bivio::Type::Password;
use Bivio::Type::UserState;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
Bivio::Agent::HTTP::Cookie->register(__PACKAGE__);
my($_USER_FIELD) = 'uid';

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok() : boolean

Sets the realm to logged in user.  If I<realm_owner> is C<undef>,
is same as logout.

Note: If you call this method with a I<realm_owner>, the cookie
will be checked.   Don't calle this method unless you expect

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    # Loaded by validate or called externally.  Set the cookie appropriately.
    my($realm) = $properties->{realm_owner};
    my($realm_id) = $realm ? $realm->get('realm_id') : undef;

    # If called directly, do some important sanity checks
    if (!$properties->{validate_called} && $realm) {
	$self->throw_die('DIE', {entity => $realm,
	    message => "can't login as offline user"})
		if $realm->is_offline_user();
	$self->throw_die('DIE', {entity => $realm,
	    entity_type => $realm->get('realm_type'),
	    message => "can't login as non-user"})
		unless $realm->get('realm_type')
			== Bivio::Auth::RealmType::USER();
	$self->throw_die('DIE', {entity => $realm,
	    message => "can't login as *the* USER realm"})
		if $realm->is_default;
    }

    # Set user first, so cookie code has a valid "auth_user"
    $req->set_user($realm);

    _trace($properties) if $_TRACE;

    # Process the cookie
    _execute_cookie($self, $req, $realm_id);

    return 0;
}

=for html <a name="handle_cookie_in"></a>

=head2 static handle_cookie_in(Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)

Sets the I<auth_user_id> if user is logged in.   Sets the user
in the log (via I<r> record).

Doesn't read the database to validate ids, simply translates values
from cookie to real code.

=cut

sub handle_cookie_in {
    my($proto, $cookie, $req) = @_;

    # Don't do anything if we don't have a user in the cookie
    my($user_id) = $cookie->unsafe_get($_USER_FIELD);
    _trace('user_id=', $user_id) if $_TRACE;
    if ($user_id) {
	# We are logged in, indicate by setting the user_id
	$req->put_durable(
		auth_user_id => $user_id,
		user_state => Bivio::Type::UserState->LOGGED_IN);
	_set_log_user($req, $user_id);
    }
    else {
	# Not logged in
	$req->put_durable(
		auth_user_id => undef,
		user_state => Bivio::Type::UserState->JUST_VISITOR);
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	# Form versions are checked and mismatches causes VERSION_MISMATCH
	version => 2,

	# This form's "next" is the task which redirected to this form.
	# If redirect was not from a task, returns to normal "next".
	require_context => 1,

	# Fields which are shown to the user.
	visible => [
	    'RealmOwner.name',
            'RealmOwner.password',
	],

	# Fields used internally which are dynamically computed dynamically.
	# They are not sent to or returned from the user.
	other => [
	    # The following fields are computed by validate
	    {
		name => 'realm_owner',
		# PropertyModels may act as types.
		type => 'Bivio::Biz::Model::RealmOwner',
		constraint => 'NONE',
	    },
	    {
		# Only set by validate
		name => 'validate_called',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;
    my($properties) = $self->internal_get;
    return unless defined($properties->{'RealmOwner.name'});

    # Emulate what happens in Type::RealmName
    my($login) = $properties->{'RealmOwner.name'};
    my($owner) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    my($expected);
    if ($login =~ /@/) {
        $expected = $owner->get('password')
                if $owner->unauth_load_by_email($login,
                        realm_type => Bivio::Auth::RealmType::USER());
        # Retry without the domain name
        $login =~ s/@.*$// unless defined($expected);
    }
    $expected = $owner->unauth_load(name => $login,
            realm_type => Bivio::Auth::RealmType::USER())
            ? $owner->get('password') : undef
                    unless defined($expected);

    # Not found or no password (don't allow to login)
    unless (defined($expected)) {
	$self->internal_put_error('RealmOwner.name',
		Bivio::TypeError::NOT_FOUND());
	return;
    }

    # Can't login is offline user (warn, because no one should do this)
    if ($owner->is_offline_user) {
	Bivio::IO::Alert->warn($owner, ": attempt to login as offline user");
	$self->internal_put_error('RealmOwner.name',
		Bivio::TypeError::NOT_FOUND());
	return;
    }

    # Can't login as *the* USER
    if ($owner->is_default) {
	Bivio::IO::Alert->warn($owner, ": attempt to login as *the* USER");
	$self->internal_put_error('RealmOwner.name',
		Bivio::TypeError::NOT_FOUND());
	return;
    }

    # User didn't enter a valid password.  Already errors on the form.
    return unless defined($properties->{'RealmOwner.password'});

    # Compare passwords
    unless (Bivio::Type::Password->is_equal($expected,
	    $properties->{'RealmOwner.password'})) {
	$self->internal_put_error('RealmOwner.password',
		Bivio::TypeError::PASSWORD_MISMATCH());
	return;
    }

    # Finally, success
    $properties->{realm_owner} = $owner;
    $properties->{validate_called} = 1;
    return;
}

#=PRIVATE METHODS

# _execute_cookie(Bivio::Biz::FormModel self, Bivio::Agent::Request req, string realm_id)
#
# Checks to see if the cookie was received.
#
sub _execute_cookie {
    my($self, $req, $realm_id) = @_;
    Bivio::PetShop::Agent::Cookie->assert_is_ok($req) if $realm_id;

    # Set login state and user (if not undef)
    my($cookie) = $req->get('cookie');
    if ($realm_id) {
	$cookie->put($_USER_FIELD => $realm_id);
    }
    else {
	$cookie->delete($_USER_FIELD);
    }
    # Update the log user
    $self->handle_cookie_in($cookie, $req);
    return;
}

# _set_log_user(Bivio::Agent::Request req, string user_id)
#
# Set the user for this connection. Shows up in the server log.
#
sub _set_log_user {
    my($req, $id) = @_;
    my($r) = $req->unsafe_get('r');
    return unless $r;

    my($name) = $_USER_FIELD .'-'. $id;
    # Set in the log (be careful not to assume 'r', because is called
    # from execute_ok and from Cookie).
    $r->connection->user($name);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
