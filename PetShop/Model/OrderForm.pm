# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::OrderForm;
use strict;
$Bivio::PetShop::Model::OrderForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::OrderForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::OrderForm - create an order for the current cart items

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::OrderForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::OrderForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::OrderForm>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::IO::Trace;
use Bivio::PetShop::Type::EntityLocation;
use Bivio::PetShop::Type::OrderStatus;
use Bivio::PetShop::Type::UserStatus;
use Bivio::Type::Date;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads the form with data defaulted for the current user.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;

    $self->internal_put_field('Order.credit_card'
	    => '9999 9999 9999 9999');
    $self->internal_put_field(ship_to_billing_address => 1);

    # name
    my($user) = Bivio::Biz::Model->new($req, 'User')->load;
    $self->internal_put_field('Order.bill_to_first_name'
	    => $user->get('first_name'));
    $self->internal_put_field('Order.bill_to_last_name'
	    => $user->get('last_name'));

    # address
    my($account) = Bivio::Biz::Model->new($req, 'UserAccount')->load;
    my($address) = Bivio::Biz::Model->new($req, 'EntityAddress')->load({
	entity_id => $account->get('entity_id'),
	location => Bivio::PetShop::Type::EntityLocation->PRIMARY,
    });
    foreach my $field (qw(addr1 addr2 city state zip country)) {
	$self->internal_put_field('EntityAddress_1.'.$field
		=> $address->get($field));
    }

    # phone
    $self->internal_put_field('EntityPhone_1.phone'
	    => Bivio::Biz::Model->new($req, 'EntityPhone')
	    ->load({
		entity_id => $account->get('entity_id'),
		location => Bivio::PetShop::Type::EntityLocation->PRIMARY,
	    })->get('phone'));

    $self->internal_put_field(confirmed_order => 0);

    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Redirects to the Shipping Address form if 'ship_to_billing_address'
is selected.

=cut

sub execute_ok {
    my($self) = @_;

    if ($self->get('confirmed_order')) {
	my($order_id) = _save_order($self);
#TODO: need to put order id on query
	$self->get_request->put(query => {p => $order_id});
	return;
    }

    _copy_billing_info($self)
	    if $self->get('ship_to_billing_address');

    unless (defined($self->get('Order.ship_to_first_name'))) {
	_trace("redirecting to shipping address page") if $_TRACE;
	$self->get_request->server_redirect(
		Bivio::Agent::TaskId->SHIPPING_ADDRESS);
	# DOES NOT RETURN
    }

    _trace("redirecting to order confirmation page") if $_TRACE;
    $self->get_request->server_redirect(
	    Bivio::Agent::TaskId->ORDER_CONFIRMATION);
    # DOES NOT RETURN
}

=for html <a name="execute_unwind"></a>

=head2 execute_unwind()

Called when returning from the shipping address or order confirmation
sub forms.

=cut

sub execute_unwind {
    my($self) = @_;

    if ($self->get('confirmed_order')) {
	$self->execute_ok;
	$self->internal_redirect_next;
	# DOES NOT RETURN
    }

    _trace("redirecting to order confirmation page") if $_TRACE;
    $self->get_request->server_redirect(
	    Bivio::Agent::TaskId->ORDER_CONFIRMATION);
    # DOES NOT RETURN
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [
	    'Order.card_type',
	    'Order.credit_card',
	    {
		name => 'card_expire_month',
		type => 'CreditCardMonth',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'card_expire_year',
		type => 'CreditCardYear',
		constraint => 'NOT_NULL',
	    },
	    # billing info
	    'Order.bill_to_first_name',
	    'Order.bill_to_last_name',
	    'EntityAddress_1.addr1',
	    'EntityAddress_1.addr2',
	    'EntityAddress_1.city',
	    'EntityAddress_1.state',
	    'EntityAddress_1.zip',
	    'EntityAddress_1.country',
	    'EntityPhone_1.phone',
	    # shipping info
	    {
		name => 'Order.ship_to_first_name',
		constraint => 'NONE',
	    },
	    {
		name => 'Order.ship_to_last_name',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityAddress_2.addr1',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityAddress_2.addr2',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityAddress_2.city',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityAddress_2.state',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityAddress_2.zip',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityAddress_2.country',
		constraint => 'NONE',
	    },
	    {
		name => 'EntityPhone_2.phone',
		constraint => 'NONE',
	    },
	    {
		name => 'ship_to_billing_address',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
	hidden => [
	    {
		name => 'confirmed_order',
		type => 'Boolean',
	        constraint => 'NOT_NULL',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

# _copy_billing_info()
#
# Copies billing information fields into shipping fields.
#
sub _copy_billing_info {
    my($self) = @_;

    # address
    foreach my $field (qw(addr1 addr2 city state zip country)) {
	$self->internal_put_field('EntityAddress_2.'.$field
		=> $self->get('EntityAddress_1.'.$field));
    }

    # phone
    $self->internal_put_field('EntityPhone_2.phone'
	    => $self->get('EntityPhone_1.phone'));

    # name
    foreach my $field (qw(first_name last_name)) {
	$self->internal_put_field('Order.ship_to_'.$field
		=> $self->get('Order.bill_to_'.$field));
    }
    return;
}

# _decrease_inventory()
#
# Reduces the inventory for items in the order.
#
sub _decrease_inventory {
    my($self) = @_;

    my($list) = Bivio::Biz::Model->new($self->get_request, 'CartItemList')
	    ->load_all;
    while ($list->next_row) {
	my($inventory) = $list->get_model('Inventory');
	$inventory->update({
	    quantity => $inventory->get('quantity')
	        - $list->get('CartItem.quantity'),
	});
    }
    return;
}

# _get_bonus_miles(string amount) : int
#
# Returns the bonus miles credited for the order.
#
# < $100 : 500 miles
# >= $100 : 1000 miles
# gold customers : + 1000 miles
#
sub _get_bonus_miles {
    my($self, $amount) = @_;
    my($miles) = $amount >= 100 ? 1000 : 500;

    if (Bivio::Biz::Model->new($self->get_request, 'UserAccount')->load->get(
	    'status') == Bivio::PetShop::Type::UserStatus->GOLD_CUSTOMER) {
	$miles += 1000;
    }
    return $miles;
}

# _get_expiration_date() : string
#
# Returns the credit card expiration date.
#
sub _get_expiration_date {
    my($self) = @_;
    my($date, $err) = Bivio::Type::Date->date_from_parts(1,
	    $self->get('card_expire_month')->as_int,
	    $self->get('card_expire_year')->as_int);
    Bivio::Die->die($err) if $err;
    return $date;
}

# _save_order() : string
#
# Creates the order models using the current information.
# Returns the order_id for the new Order.
#
sub _save_order {
    my($self) = @_;
    my($req) = $self->get_request;

    my($cart) = Bivio::Biz::Model->new($req, 'Cart')->load({
	cart_id => $req->get('cart_id'),
    });
    my($total) = $cart->get_total;

    # create the entity and order
    my($order) = Bivio::Biz::Model->new($req, 'Order')->create({
	order_id => Bivio::Biz::Model->new($req, 'Entity')->create({})
	    ->get('entity_id'),
	user_id => $req->get('auth_user_id'),
	cart_id => $cart->get('cart_id'),
	order_date => Bivio::Type::Date->now,
	courier => 'UPS',
	bonus_miles => _get_bonus_miles($self, $total),
	total_price => $total,
	expiration_date => _get_expiration_date($self),
	%{$self->get_model_properties('Order')},
    });

    # create the entity address/phone for billing/shipping
    foreach my $location (qw(BILL_TO SHIP_TO)) {
	Bivio::Biz::Model->new($req, 'EntityAddress')->create({
	    entity_id => $order->get('order_id'),
	    location => Bivio::PetShop::Type::EntityLocation->$location(),
	    %{$self->get_model_properties('EntityAddress_'
		    .($location eq 'BILL_TO' ? 1 : 2))},
	});

	Bivio::Biz::Model->new($req, 'EntityPhone')->create({
	    entity_id => $order->get('order_id'),
	    location => Bivio::PetShop::Type::EntityLocation->$location(),
	    %{$self->get_model_properties('EntityPhone_'
		    .($location eq 'BILL_TO' ? 1 : 2))},
	});
    }

    # create the order status
    Bivio::Biz::Model->new($req, 'OrderStatus')->create({
	order_id => $order->get('order_id'),
	user_id => $req->get('auth_user_id'),
	time_stamp => $order->get('order_date'),
	status => Bivio::PetShop::Type::OrderStatus->PENDING,
    });

    _decrease_inventory($self);

    return $order->get('order_id');
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
