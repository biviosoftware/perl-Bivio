# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListModel::T2List;
use strict;
$Bivio::Biz::t::ListModel::T2List::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::t::ListModel::T2List::VERSION;

=head1 NAME

Bivio::Biz::t::ListModel::T2List - t

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::t::ListModel::T2List;

=cut

=head1 EXTENDS

L<Bivio::Biz::t::ListModel::T1List;

=cut

use Bivio::Biz::t::ListModel::T1List;
@Bivio::Biz::t::ListModel::T2List::ISA = ('Bivio::Biz::t::ListModel::T1List');

=head1 DESCRIPTION

C<Bivio::Biz::t::ListModel::T2List>

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

=for html <a name="internal_prepare_statement"></a>

=head2 internal_prepare_statement(Bivio::SQL::Statement statement)

=cut

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(['RealmOwner.realm_id', [3]]);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
