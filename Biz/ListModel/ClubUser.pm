# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel::ClubUser;
use strict;
$Bivio::Biz::ListModel::ClubUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel::ClubUser - a list of ClubUser information

=head1 SYNOPSIS

    use Bivio::Biz::ListModel::ClubUser;
    Bivio::Biz::ListModel::ClubUser->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::ListModel::ClubUser::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::ListModel::ClubUser>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	order_by => [qw(
            RealmOwner.name
            ClubUser.mail_mode
            RealmUser.role
	)],
	other => [qw(
	    User.last_name
	)],
	primary_key => [
	    [qw(User.user_id ClubUser.user_id RealmOwner.realm_id
                RealmUser.user_id)],
	],
	auth_id => [qw(ClubUser.club_id RealmUser.realm_id)],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
