# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Inventory;
use strict;
$Bivio::PetShop::Model::Inventory::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::Inventory::VERSION;

=head1 NAME

Bivio::PetShop::Model::Inventory - item inventory

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::Inventory;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::Inventory::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::Inventory>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'inventory_t',
	columns => {
	    item_id => ['Item.item_id', 'PRIMARY_KEY'],
	    quantity => ['Integer', 'NOT_NULL'],
	},
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
