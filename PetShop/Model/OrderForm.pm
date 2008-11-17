# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
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
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::Type::Date;
use Bivio::Type::ECPaymentMethod;
use Bivio::Type::ECPaymentStatus;
use Bivio::Type::ECPointOfSale;
use Bivio::Type::ECService;
use Bivio::Type::Location;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads the form with data defaulted for the current user.

=cut

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('ECCreditCardPayment.card_number' =>
        '4222 2222 2222 2');
    $self->internal_put_field(ship_to_billing_address => 1);

    # name
    my($user) = $self->new_other('User')->load;
    $self->internal_put_field('Order.bill_to_name' => $user->format_full_name);

    # address and phone
    foreach my $model (qw(Address Phone)) {
	$self->load_from_model_properties(
            $self->new_other($model)->load({
                location => Bivio::Type::Location->PRIMARY,
            }));
    }
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
        $self->get_request->set_realm(_save_order($self));
	return;
    }
    _copy_billing_info($self)
        if $self->get('ship_to_billing_address');

    unless (defined($self->get('Order.ship_to_name'))) {
#TODO: try returning task id
	_trace('redirecting to shipping address page') if $_TRACE;
	$self->get_request->server_redirect(
            Bivio::Agent::TaskId->SHIPPING_ADDRESS);
	# DOES NOT RETURN
    }
#TODO: try returning task id
    _trace('redirecting to order confirmation page') if $_TRACE;
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
	_trace('order confirmed, redirecting to next') if $_TRACE;
	$self->execute_ok;
	return $self->internal_redirect_next;
    }
    _trace('redirecting to order confirmation page') if $_TRACE;
    return {
	method => 'server_redirect',
        task_id => Bivio::Agent::TaskId->ORDER_CONFIRMATION,
    };
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
            'ECCreditCardPayment.card_number',
  	    {
  		name => 'card_expire_month',
  		type => 'ECCreditCardExpMonth',
  		constraint => 'NOT_NULL',
  	    },
  	    {
  		name => 'card_expire_year',
  		type => 'ECCreditCardExpYear',
  		constraint => 'NOT_NULL',
  	    },
	    # billing info
            map({
                {
                    name => $_,
                    constraint => 'NOT_NULL',
                },
            } (qw(Order.bill_to_name Address.street1 Address.city
                Address.state Address.zip))),
            'Address.country',
            'Address.street2',
            'Phone.phone',
	    # shipping info
            map({
                {
                    name => $_,
                    constraint => 'NONE',
                }
            } (qw(Order.ship_to_name Address_2.street1 Address_2.street2
                Address_2.city Address_2.state Address_2.zip Address_2.country
                Phone_2.phone))),
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
    });
}

#=PRIVATE METHODS

# _copy_billing_info()
#
# Copies billing information fields into shipping fields.
#
sub _copy_billing_info {
    my($self) = @_;

    # address
    foreach my $field (qw(street1 street2 city state zip country)) {
	$self->internal_put_field('Address_2.' . $field =>
            $self->get('Address.' . $field));
    }

    # phone
    $self->internal_put_field('Phone_2.phone' =>
        $self->get('Phone.phone'));

    # name
    $self->internal_put_field('Order.ship_to_name' =>
        $self->get('Order.bill_to_name'));
    return;
}

# _decrease_inventory()
#
# Reduces the inventory for items in the order.
#
sub _decrease_inventory {
    my($self) = @_;
    my($list) = $self->new_other('CartItemList')->load_all;

    while ($list->next_row) {
	my($inventory) = $list->get_model('Inventory');
	$inventory->update({
	    quantity => $inventory->get('quantity')
	        - $list->get('CartItem.quantity'),
	});
    }
    return;
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
# Returns the realm_id for the new Order.
#
sub _save_order {
    my($self) = @_;
    my($cart) = $self->new_other('Cart')->load_from_cookie;
    my($order) = $self->new_other('Order')->create({
        cart_id => $cart->get('cart_id'),
        %{$self->get_model_properties('Order')},
    });
    $self->new_other('RealmOwner')->create({
        display_name => 'Order ' . $order->get('order_id'),
        name => 'o' . $order->get('order_id'),
        realm_type => Bivio::Auth::RealmType->ORDER,
        realm_id => $order->get('order_id'),
    });
    $self->new_other('ECCreditCardPayment')->create({
        realm_id => $order->get('order_id'),
        ec_payment_id => $self->new_other('ECPayment')->create({
            realm_id => $order->get('order_id'),
            amount => $cart->get_total,
            method => Bivio::Type::ECPaymentMethod->CREDIT_CARD,
            status => Bivio::Type::ECPaymentStatus->TRY_CAPTURE,
            service => Bivio::Type::ECService->ANIMAL,
            point_of_sale => Bivio::Type::ECPointOfSale->INTERNET,
        })->get('ec_payment_id'),
        card_name => $self->get('Order.bill_to_name'),
        card_expiration_date => _get_expiration_date($self),
        card_zip => $self->get('Address.zip'),
        %{$self->get_model_properties('ECCreditCardPayment')},
    });

    # create the entity address/phone for billing/shipping
    foreach my $location (qw(BILL_TO SHIP_TO)) {

        foreach my $model (qw(Address Phone)) {
            $self->new_other($model)->create({
                realm_id => $order->get('order_id'),
                location => Bivio::Type::Location->from_name($location),
                %{$self->get_model_properties($model
                    . ($location eq 'BILL_TO' ? '' : '_2'))},
            });
        }
    }
    # grant the user access to view the order
    $self->new_other('RealmUser')->create({
        realm_id => $order->get('order_id'),
        user_id => $self->get_request->get('auth_user_id'),
        role => Bivio::Auth::Role->MEMBER,
    });
    _decrease_inventory($self);
    return $order->get('order_id');
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
