# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::SubstituteUserForm;
use strict;
$Bivio::Biz::Model::SubstituteUserForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::SubstituteUserForm - allows general admin to become other user

=head1 SYNOPSIS

    use Bivio::Biz::Model::SubstituteUserForm;
    Bivio::Biz::Model::SubstituteUserForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::SubstituteUserForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::SubstituteUserForm> allows a general admin to
become another user.
Sets the special cookie value
so we know the we are operating in super-user mode.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK : string

Returns login button.

=cut

sub SUBMIT_OK {
    return ' Login ';
}

=for html <a name="SUBMIT_CANCEL"></a>

=head2 SUBMIT_CANCEL : string

There is no cancel button for login forms.

=cut

sub SUBMIT_CANCEL {
    return '';
}

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

=for html <a name="execute_input"></a>

=head2 execute_input()

Logs in the I<realm_owner> and updates the cookie.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($req) = $self->get_request;
    my($cookie) = $req->get('cookie');

    my($new_user) = $properties->{realm_owner};
    if (defined($new_user)) {
	# Set (Login)
	unless ($cookie->unsafe_get($_SU_FIELD)) {
	    # Only set cookie field if not already set.  This keeps original
	    # user and doesn't allow someone to su to an admin and then su
	    # as that admin.
	    my($super_user_id) = $req->get('auth_user')->get('realm_id');
	    $cookie->put($_SU_FIELD => $super_user_id);
	    $req->put(super_user_id => $super_user_id);
	}

	# Execute the login
	Bivio::Biz::Model::LoginForm->execute($req,
		{realm_owner => $new_user});
	return;
    }

    # Unset (Logout)
    my($super_user_id) = $req->unsafe_get('super_user_id');
    if ($super_user_id) {
	$req->delete('super_user_id');
	$cookie->delete($_SU_FIELD);
	# Load the super user and unset
	my($new_user) = Bivio::Biz::Model::RealmOwner->new($req);
	if ($new_user->unauth_load(
		realm_id => $super_user_id,
		realm_type => Bivio::Auth::RealmType::USER())) {
	    # Loaded super user, so set as ordinary user and redirect to
	    # SU task again
	    Bivio::Biz::Model::LoginForm->execute($req,
		    {realm_owner => $new_user});
	    $req->client_redirect(Bivio::Agent::TaskId::SUBSTITUTE_USER());
	    # DOES NOT RETURN
	}

	# Unable to load super user (no permissions), so ordinary logout
    }
    Bivio::Biz::Model::LoginForm->execute($req,
	    {realm_owner => undef});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
	    {
		name => 'login',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    {
		name => 'realm_owner',
		type => 'Bivio::Biz::Model::RealmOwner',
		constraint => 'NONE',
	    },
	],
	auth_id => ['RealmOwner.realm_id'],
	primary_key => [
	    'RealmOwner.realm_id',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Look up the user by email, user_id, or name.

=cut

sub validate {
    my($self) = @_;
    my($properties) = $self->internal_get();
    return unless defined($properties->{'login'});

    # Emulate what happens in Type::RealmName
    $properties->{'login'} = lc($properties->{'login'});
    $properties->{'login'} =~ s/\s+//g;

    my($login) = $properties->{'login'};
    my($owner) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $properties->{realm_owner} = $owner;
    if ($login =~ /@/) {
	# Login by email
	return if $owner->unauth_load_by_email($login,
		{realm_type => Bivio::Auth::RealmType::USER()});
    }
    elsif ($login =~ /^\d/) {
	# Login by realm id
	return if $owner->unauth_load(realm_id => $login,
		{realm_type => Bivio::Auth::RealmType::USER()});
    }
    else {
	# Login by name
	return if $owner->unauth_load(name => $login,
		realm_type => Bivio::Auth::RealmType::USER());
    }

    # Failed
    $self->internal_put_error('login', Bivio::TypeError::NOT_FOUND());
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
