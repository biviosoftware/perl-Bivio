# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AdmSubstituteUserForm;
use strict;
$Bivio::Biz::Model::AdmSubstituteUserForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmSubstituteUserForm::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmSubstituteUserForm - allows general admin to become other user

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmSubstituteUserForm;
    Bivio::Biz::Model::AdmSubstituteUserForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AdmSubstituteUserForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmSubstituteUserForm> allows a general admin to
become another user.
Sets the special cookie value
so we know the we are operating in super-user mode.

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::Biz::Model::LoginForm;
use Bivio::SQL::Constraint;
use Bivio::Type::Hash;
use Bivio::Type::Text;
use Bivio::TypeError;

#=VARIABLES
# Cookie handled by LoginForm::handle_cookie_in
my($_SU_FIELD) = Bivio::Agent::HTTP::Cookie->SU_FIELD();

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Perform lookup and su automatically if coming in with query string.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->internal_put_field(next_task =>
	Bivio::Societas::Biz::Model::Preferences
	    ->get_user_pref($req, 'ADM_SU_NEXT_TASK')
	|| $req->get('task')->get('next'));
    my($query) = $req->unsafe_get('query');
    my($this) = $query->{Bivio::SQL::ListQuery->to_char('this')};
    return unless $this;
    $self->internal_put_field(login => $this);
    $self->validate_and_execute_ok();
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok() : boolean

Logs in the I<realm_owner> and updates the cookie.

=cut

sub execute_ok {
    my($self) = @_;
    my($properties) = $self->internal_get;
    unless ($properties->{validate_called}) {
	$self->validate;
	return if $self->in_error;
	# Note that "realm_owner" may be undef
    }

    my($req) = $self->get_request;
    my($cookie) = $req->unsafe_get('cookie');
    my($new_user) = $properties->{realm_owner};
    if (defined($new_user)) {
	# Set (Login)
	unless ($req->unsafe_get('super_user_id')) {
	    # Only set super_user_id field if not already set.  This keeps
	    # original user and doesn't allow someone to su to an admin and
	    # then su as that admin.
	    my($super_user_id) = $req->get('auth_user')->get('realm_id');
	    $cookie->put($_SU_FIELD => $super_user_id) if $cookie;
	    $req->put(super_user_id => $super_user_id);
	}

	# Set the preference before su'ing
	Bivio::Societas::Biz::Model::Preferences->set_user_pref(
	    $req, 'ADM_SU_NEXT_TASK', $properties->{next_task});

	# MUST BE LAST (may redirect)
	Bivio::Biz::Model::LoginForm->execute($req,
		{realm_owner => $new_user});
	$req->client_redirect(Bivio::UI::Task->format_realmless_uri(
	    $properties->{next_task}, undef, $req))
	    if ref($properties->{next_task});
	return 0;
    }

    # Unset (Logout)
    my($super_user_id) = $req->unsafe_get('super_user_id');
    if ($super_user_id) {
	$req->delete('super_user_id');
	$cookie->delete($_SU_FIELD) if $cookie;
	# Load the super user and unset
	my($new_user) = Bivio::Biz::Model::RealmOwner->new($req);
	if ($new_user->unauth_load(
		realm_id => $super_user_id,
		realm_type => Bivio::Auth::RealmType::USER())) {
	    # Loaded super user, so set as ordinary user and redirect to
	    # SU task again
	    Bivio::Biz::Model::LoginForm->execute($req,
		    {realm_owner => $new_user});
	    $req->client_redirect(Bivio::Agent::TaskId::ADM_SUBSTITUTE_USER());
	    # Job::Dispatcher may ignore_redirects.  Forms must be coded
	    # specially.
	    return 0;
	}

	# Unable to load super user (no permissions), so ordinary logout
    }

    # MUST BE LAST (may redirect)
    Bivio::Biz::Model::LoginForm->execute($req,
	    {realm_owner => undef});
    return 0;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [
	    {
		name => 'login',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'next_task',
		type => 'Bivio::Agent::TaskId',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		name => 'realm_owner',
		type => 'Bivio::Biz::Model::RealmOwner',
		constraint => 'NONE',
	    },
	    {
		# Do not set this if validate was not called
		name => 'validate_called',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
	auth_id => ['RealmOwner.realm_id'],
	primary_key => [
	    'RealmOwner.realm_id',
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Look up the user by email, user_id, or name.

=cut

sub validate {
    my($self) = @_;
    my($properties) = $self->internal_get();
    $properties->{validate_called} = 1;
    return unless defined($properties->{login});

    # Emulate what happens in Type::RealmName
    $properties->{login} = lc($properties->{login});
    $properties->{login} =~ s/\s+//g;

    # Try to load
    my($login) = $properties->{'login'};
    my($owner) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $properties->{realm_owner} = $owner;
    if ($owner->unauth_load_by_email_id_or_name($login)) {
	# No offline users please
	if ($owner->is_offline_user) {
	    $self->internal_put_error('login', 'OFFLINE_USER');
	    return;
	}

	# Got a user
	return if $owner->get('realm_type') == Bivio::Auth::RealmType::USER();

	# Got a club?  Go to first admin
	if ($owner->get('realm_type') == Bivio::Auth::RealmType::CLUB()) {
	    return if $owner->unauth_load(realm_id =>
		Bivio::Biz::Model->get_instance('RealmAdminList')
		->get_first_admin($owner),
		realm_type => Bivio::Auth::RealmType::USER());
	}
    }
    $self->internal_put_error('login', Bivio::TypeError::NOT_FOUND());
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
