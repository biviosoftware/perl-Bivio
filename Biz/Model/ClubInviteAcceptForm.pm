# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ClubInviteAcceptForm;
use strict;
$Bivio::Biz::Model::ClubInviteAcceptForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ClubInviteAcceptForm - used by user to join club

=head1 SYNOPSIS

    use Bivio::Biz::Model::ClubInviteAcceptForm;
    Bivio::Biz::Model::ClubInviteAcceptForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ClubInviteAcceptForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::ClubInviteAcceptForm> user uses this to join a
club.

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::SQL::Constraint;
use Bivio::Type::ClubUserTitle;
use Bivio::UI::Mail::UserJoined;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Makes sure user is logged in.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    unless ($req->get('auth_user')) {
#TODO: Put something in the form that says "please login first"
#      Probably need to sign up.  Check the email as a hint.
#      Need tow guesses and forms: has login and new user
#      Probably want login on create user form and want
#      create user on login
	$req->server_redirect(Bivio::Agent::TaskId::LOGIN());
	# DOES NOT RETURN
    }
#TODO: Make sure there really is an invite for this club with this id.
# Probably do everything in validate
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Adds auth_user to the club.  Deletes the invitation.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($req) = $self->get_request;
    my($user, $realm_id, $invite) = $req->get('auth_user', 'auth_id',
	    'Bivio::Biz::Model::RealmInvite');

    # User needs to login
    unless ($user) {
#TODO: Put something in the form that says "please login first"
#      Probably need to sign up.  Check the email as a hint.
#      Need tow guesses and forms: has login and new user
#      Probably want login on create user form and want
#      create user on login
	$req->server_redirect(Bivio::Agent::TaskId::LOGIN());
	# DOES NOT RETURN
    }

    # Create the realm_user
    my($role, $title) = $invite->get('role', 'title');
    my($model) = Bivio::Biz::Model::RealmUser->new($req);
    $model->create({
	realm_id => $realm_id,
	# The auth_user may be someone else than auth_realm, because
	# the user may have given club create privileges to the other
	# person.
	user_id => $req->get('auth_user')->get('realm_id'),
	role => $role,
	title => $title,
    });

    # Destroy invitation
    $invite->delete();
#TODO: This is just wrong.  Because forms client_redirect, can't
#      go to the next item which isn't an URL.
    Bivio::UI::Mail::UserJoined->execute($req);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
    };
}

=for html <a name="validate"></a>

=head2 validate()

Does nothing.

=cut

sub validate {
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
