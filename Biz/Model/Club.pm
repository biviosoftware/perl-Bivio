# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Club;
use strict;
$Bivio::Biz::Model::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Club::VERSION;

=head1 NAME

Bivio::Biz::Model::Club - interface to club_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::Club;
    Bivio::Biz::Model::Club->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Club::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Club> is the create, read, update,
and delete interface to the C<club_t> table.

=cut

#=IMPORTS
# also uses RealmUserList
use Bivio::Auth::RealmType;
use Bivio::Auth::RoleSet;
use Bivio::Biz::Accounting::Ratio;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::SQL::Connection;
use Bivio::Type::Amount;
use Bivio::Type::DateTime;
use Bivio::Type::RealmName;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this club and all its related realm information. Also deletes
any offline members which are a member of the club.

=cut

sub cascade_delete {
    my($self) = @_;
    my($realm) = Bivio::Biz::Model->new($self->get_request, 'RealmOwner')
	    ->unauth_load_or_die(realm_id => $self->get('club_id'));

    # need to load the user list first, delete offline members last
    my($user_list) = Bivio::Biz::Model->new($self->get_request,
	    'RealmUserList')->load_all_with_inactive;
    $self->SUPER::cascade_delete;
    $realm->cascade_delete;
    $user_list->delete_offline_users;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'club_t',
	columns => {
            club_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    start_date => ['Date', 'NONE'],
        },
	auth_id => 'club_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
