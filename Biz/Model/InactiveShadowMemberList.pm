# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InactiveShadowMemberList;
use strict;
$Bivio::Biz::Model::InactiveShadowMemberList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InactiveShadowMemberList - lists inactive shadow member

=head1 SYNOPSIS

    use Bivio::Biz::Model::InactiveShadowMemberList;
    Bivio::Biz::Model::InactiveShadowMemberList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::InactiveShadowMemberList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InactiveShadowMemberList> lists inactive shadow member

=cut

#=IMPORTS
use Bivio::Auth::Role;

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
    push(@{$res->{where}},
	    'AND',
	    'RealmUser.role', '=',
	    Bivio::Auth::Role::WITHDRAWN->as_sql_param,
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
