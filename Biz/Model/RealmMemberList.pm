# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmMemberList;
use strict;
$Bivio::Biz::Model::RealmMemberList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmMemberList - simple list of members for a realm

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmMemberList;
    Bivio::Biz::Model::RealmMemberList->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::RealmMemberList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmMemberList>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmUser;
use Bivio::Auth::RoleSet;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($roles) = Bivio::Biz::Model::RealmUser->MEMBER_ROLES();
    return {
	version => 1,
	order_by => [qw(
            RealmOwner.name
            RealmOwner.display_name
	)],
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id)],
	],
	auth_id => [qw(RealmUser.realm_id)],
	other => [qw(
	    RealmUser.role
	)],
	where => [
	    'RealmUser.role',
	    'IN',
	    Bivio::Auth::RoleSet->to_sql_list(\$roles),
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
