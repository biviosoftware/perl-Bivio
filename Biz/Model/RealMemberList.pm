# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealMemberList;
use strict;
$Bivio::Biz::Model::RealMemberList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealMemberList - lists a club's on-line members

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealMemberList;
    Bivio::Biz::Model::RealMemberList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::ClubUserList>

=cut

use Bivio::Biz::Model::ClubUserList;
@Bivio::Biz::Model::RealMemberList::ISA = ('Bivio::Biz::Model::ClubUserList');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealMemberList> lists a club's true members

=cut

#=IMPORTS
use Bivio::Auth::RoleSet;
use Bivio::Biz::Model::RealmOwner;

#=VARIABLES
my($_SHADOW_PREFIX) = Bivio::Biz::Model::RealmOwner->SHADOW_PREFIX();

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($proto) = @_;
    my($res) = $proto->SUPER::internal_initialize();
    my($roles) = Bivio::Biz::Model::RealmUser->MEMBER_ROLES();
    push(@{$res->{other}},
	    [qw(RealmUser.user_id TaxId.realm_id)],
	    'TaxId.tax_id');
    push(@{$res->{where}},
	'AND',
	'RealmOwner.name', 'NOT LIKE', "'$_SHADOW_PREFIX%'",
	'AND',
	'RealmUser.role',
	'IN',
	Bivio::Auth::RoleSet->to_sql_list(\$roles),
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
