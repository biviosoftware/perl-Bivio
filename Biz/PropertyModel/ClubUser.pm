# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::ClubUser;
use strict;
$Bivio::Biz::PropertyModel::ClubUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::ClubUser - user settings related to a specific club

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::ClubUser;
    Bivio::Biz::PropertyModel::ClubUser->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::ClubUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::ClubUser>

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::PropertyModel::Club;
use Bivio::Biz::PropertyModel::User;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_club"></a>

=head2 get_club() : Bivio::Biz::PropertyModel::Club

Returns the club model associated with this model.

=cut

sub get_club {
    my($self) = @_;
    my($club) = Bivio::Biz::PropertyModel::Club->new($self->get_request);
    $club->unauth_load('club_id' => $self->get('club_id'))
	    || die('integrity constraint failed: missing club');
    return $club;
}

=for html <a name="get_user"></a>

=head2 get_user() : Bivio::Biz::PropertyModel::User

Returns the user model associated with this model.

=cut

sub get_user {
    my($self) = @_;
    my($user) = Bivio::Biz::PropertyModel::User->new($self->get_request);
    $user->unauth_load('user_id' => $self->get('user_id'))
	    || die('integrity constraint failed: missing user');
    return $user;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'club_id' => ['Club Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'user_id' => ['User Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'email_mode' => ['Email Forwarded',
		Bivio::Biz::FieldDescriptor->lookup('BOOLEAN', 1)]
    };
    return [$property_info,
	    Bivio::SQL::Support->new('club_user_t', keys(%$property_info)),
	    ['club_id', 'user_id']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
