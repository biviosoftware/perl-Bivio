# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InviteGuestForm;
use strict;
$Bivio::Biz::Model::InviteGuestForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InviteGuestForm - invite a guest to the club

=head1 SYNOPSIS

    use Bivio::Biz::Model::InviteGuestForm;
    Bivio::Biz::Model::InviteGuestForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InviteGuestForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InviteGuestForm> invite a guest to the club

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmInvite;
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

    # send an invite to the person as a guest
    my($guest) = Bivio::Type::ClubUserTitle::GUEST();
    my($invite) = Bivio::Biz::Model::RealmInvite->new($req);
    $invite->create({
	realm_id => $req->get('auth_id'),
	email => $self->get('RealmInvite.email'),
	title => $guest->get_short_desc,
	role => $guest->get_role,
    });

    # send email an invitation
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
	    'RealmInvite.email',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Validates the member's full name.

=cut

sub validate {
    my($self) = @_;

    my($email) = $self->get('RealmInvite.email');
    if (defined($email)) {
	my($req) = $self->get_request;
	my($realm_id) = $req->get('auth_id');
	my($invite) = Bivio::Biz::Model::RealmInvite->new($req);
	if ($invite->unsafe_load(email => $email)) {
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
