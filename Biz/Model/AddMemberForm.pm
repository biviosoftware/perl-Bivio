# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AddMemberForm;
use strict;
$Bivio::Biz::Model::AddMemberForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::AddMemberForm - adds a member, optionally sends invite

=head1 SYNOPSIS

    use Bivio::Biz::Model::AddMemberForm;
    Bivio::Biz::Model::AddMemberForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AddMemberForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AddMemberForm> adds a member, optionally sends invite

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::CreateUserForm;
use Bivio::Biz::Model::RealmInvite;
use Bivio::Data::EW::ClubImporter;
use Bivio::TypeError;
use Bivio::Type::ClubUserTitle;
use Bivio::UI::Mail::ClubInvite;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Creates the shadow user from the name.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request;
    my($realm) = $req->get('auth_realm')->get('owner');

    my($email, $first, $middle, $last) = $self->unsafe_get('RealmInvite.email',
	    'User.first_name', 'User.middle_name', 'User.last_name');

#TODO: needs to be moved to the User model
    my($importer) = Bivio::Data::EW::ClubImporter->new($realm);
    my($realm_user) = $importer->create_user({
	first_name => $first,
	middle_name => $middle,
	last_name => $last,
    }, {});

    # if no email then we're done, redirect to edit the user
    unless ($email) {
	$req->server_redirect(Bivio::Agent::TaskId::CLUB_ADMIN_USER_DETAIL(),
		$req->get('auth_realm'),
#TODO: shows rather intimate knowledge of the query format
		{t => $realm_user->get('user_id'), v => 1});
	# doesn't return
    }

    # send an invite to the person as a member
    my($member) = Bivio::Type::ClubUserTitle::MEMBER();
    my($invite) = Bivio::Biz::Model::RealmInvite->new($req);
    $invite->create({
	realm_id => $req->get('auth_id'),
	realm_user_id => $realm_user->get('user_id'),
	email => $self->get('RealmInvite.email'),
	title => $member->get_short_desc,
	role => $member->get_role,
    });

    # Finally, send email an invitation
    Bivio::UI::Mail::ClubInvite->execute($self->get_request);

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
	    'RealmOwner.display_name',
	    {
		name => 'RealmInvite.email',
		type => 'Email',
		constraint => 'NONE',
	    },
	],
	other => [
	    'User.first_name',
	    'User.middle_name',
	    'User.last_name',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Validates the member's full name.

=cut

sub validate {
    my($self) = @_;
    my($properties) = $self->internal_get;

    Bivio::Biz::Model::CreateUserForm->parse_display_name($self, $properties);

    if (defined($properties->{'RealmInvite.email'})) {
	my($req) = $self->get_request;
	my($realm_id) = $req->get('auth_id');
	my($invite) = Bivio::Biz::Model::RealmInvite->new($req);
	if ($invite->unsafe_load(
		email => $properties->{'RealmInvite.email'})) {
	    $self->internal_put_error('RealmInvite.email',
		    Bivio::TypeError::ALREADY_INVITED())
	}
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
