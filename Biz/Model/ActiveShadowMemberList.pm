# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ActiveShadowMemberList;
use strict;
$Bivio::Biz::Model::ActiveShadowMemberList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ActiveShadowMemberList - lists active shadow member

=head1 SYNOPSIS

    use Bivio::Biz::Model::ActiveShadowMemberList;
    Bivio::Biz::Model::ActiveShadowMemberList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::ClubUserList>

=cut

use Bivio::Biz::Model::ClubUserList;
@Bivio::Biz::Model::ActiveShadowMemberList::ISA = ('Bivio::Biz::Model::ClubUserList');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ActiveShadowMemberList> lists active shadow member

=cut

=head1 CONSTANTS

=cut

=for html <a name="NOT_FOUND_IF_EMPTY"></a>

=head2 NOT_FOUND_IF_EMPTY : boolean

Returns false.  OK not to have active shadow members.

=cut

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

#=IMPORTS
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::Auth::RoleSet;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($proto) = @_;
    my($res) = $proto->SUPER::internal_initialize();
    push(@{$res->{other}},
	    [qw(RealmUser.user_id TaxId.realm_id)],
	    'TaxId.tax_id');
    my($shadow) = Bivio::Biz::Model::RealmOwner->SHADOW_PREFIX();
    my($roles) = Bivio::Biz::Model::RealmUser->MEMBER_ROLES();
    push(@{$res->{where}},
	    'AND',
	    'RealmUser.role', 'IN',
	    Bivio::Auth::RoleSet->to_sql_list(\$roles),
	    'AND',
	    'RealmOwner.name', 'LIKE', "'$shadow%'",
    );
    return $res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
