# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Order;
use strict;
$Bivio::PetShop::Model::Order::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::Order::VERSION;

=head1 NAME

Bivio::PetShop::Model::Order - user account order

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::Order;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::Order::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::Order>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'order_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    cart_id => ['Cart.cart_id', 'NOT_NULL'],
            ec_payment_id => ['ECPayment.ec_payment_id', 'NOT_NULL'],
            bill_to_name => ['Line', 'NOT_NULL'],
	    ship_to_name => ['Line', 'NOT_NULL'],
	},
	auth_id => 'realm_id',
        other => [
            [qw(ec_payment_id ECPayment.ec_payment_id)],
        ],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
