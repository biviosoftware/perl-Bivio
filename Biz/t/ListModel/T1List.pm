# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListModel::T1List;
use strict;
$Bivio::Biz::t::ListModel::T1List::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::t::ListModel::T1List::VERSION;

=head1 NAME

Bivio::Biz::t::ListModel::T1List - t

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::t::ListModel::T1List;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::t::ListModel::T1List::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::t::ListModel::T1List>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Simple list of users.

=cut

sub internal_initialize {
    return {
	version => 1,
	primary_key => ['RealmOwner.realm_id'],
	can_iterate => 1,
	order_by => [
	    'RealmOwner.name',
        ],
    };
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

=cut

sub internal_pre_load {
    my($self, undef, undef, $params) = @_;
    push(@$params, 3);
    return 'realm_id = ?';
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
