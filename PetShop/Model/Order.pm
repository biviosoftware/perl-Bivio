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
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_status"></a>

=head2 get_status() : Bivio::PetShop::Type::OrderStatus

Returns the current status for the order.

sub get_status {
    my($self) = @_;
    return Bivio::Biz::Model->new($self->get_request, 'OrderStatus')->load({
	order_id => $self->get('order_id'),
    })->get('status');
}

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
            order_id => ['Entity.entity_id', 'PRIMARY_KEY'],
	    cart_id => ['Cart.cart_id', 'NOT_NULL'],
	    user_id => ['UserAccount.user_id', 'NOT_NULL'],
	    order_date => ['Date', 'NOT_NULL'],
	    courier => ['Line', 'NOT_NULL'],
	    total_price => ['Price', 'NOT_NULL'],
	    bill_to_first_name => ['Line', 'NOT_NULL'],
	    bill_to_last_name => ['Line', 'NOT_NULL'],
	    ship_to_first_name => ['Line', 'NOT_NULL'],
	    ship_to_last_name => ['Line', 'NOT_NULL'],
	    credit_card => ['CreditCard', 'NOT_NULL'],
	    expiration_date => ['Date', 'NOT_NULL'],
	    card_type => ['CardType', 'NOT_NULL'],
	    bonus_miles => ['Integer', 'NONE'],
	},
	auth_id => 'user_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
