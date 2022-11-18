# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::OrderForm;
use strict;
use Bivio::Base 'Model.ECCreditCardPaymentForm';

my($_L) = b_use('Type.Location');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(ship_to_billing_address => 1);
    $self->internal_put_field(
        'Order.bill_to_name' => $self->req(qw(auth_user display_name)));

    foreach my $model (qw(Address Phone)) {
        $self->load_from_model_properties($self->new_other($model)->load);
    }
    return shift->SUPER::execute_empty(@_);
}

sub execute_ok {
    # Redirects to the Shipping Address form if 'ship_to_billing_address'
    # is selected.
    my($self) = @_;
    _copy_billing_info($self)
        if $self->get('ship_to_billing_address');
    return {
        method => 'server_redirect',
        task_id => 'SHIPPING_ADDRESS',
    }
        unless defined($self->get('Order.ship_to_name'));
    $self->check_redirect_to_confirmation_form('ORDER_CONFIRMATION');
    my($order) = _save_order($self);
    $self->req->set_realm($order->get('order_id'))
        unless $self->in_error;
    return;
}

sub execute_unwind {
    my($self) = @_;
    $self->check_redirect_to_confirmation_form('ORDER_CONFIRMATION');
    return shift->SUPER::execute_unwind(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            # billing info
            map(+{
                name => $_,
                constraint => 'NOT_NULL',
            }, qw(
                Order.bill_to_name
                Address.street1
                Address.city
                Address.state
                Address.zip
             )),
            'Address.country',
            'Address.street2',
            'Phone.phone',
            # shipping info
            map(+{
                name => $_,
                constraint => 'NONE',
            }, qw(
                Order.ship_to_name
                Address_2.street1
                Address_2.street2
                Address_2.city
                Address_2.state
                Address_2.zip
                Address_2.country
                Phone_2.phone
            )),
            {
                name => 'ship_to_billing_address',
                type => 'Boolean',
                constraint => 'NOT_NULL',
            },
        ],
        other => [
            'ECCreditCardPayment.card_name',
            'ECCreditCardPayment.card_zip',
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
        'ECCreditCardPayment.card_name' => $self->get('Order.bill_to_name'),
        'ECCreditCardPayment.card_zip' => $self->get('Address.zip'),
    );
    return @res;
}

sub _copy_billing_info {
    # Copies billing information fields into shipping fields.
    my($self) = @_;

    foreach my $field (qw(street1 street2 city state zip country)) {
        $self->internal_put_field('Address_2.' . $field =>
            $self->get('Address.' . $field));
    }
    $self->internal_put_field('Phone_2.phone' => $self->get('Phone.phone'));
    $self->internal_put_field('Order.ship_to_name' =>
        $self->get('Order.bill_to_name'));
    return;
}

sub _decrease_inventory {
    # Reduces the inventory for items in the order.
    my($self) = @_;
    $self->new_other('CartItemList')->load_all->do_rows(
        sub {
            my($list) = @_;
            my($inventory) = $list->get_model('Inventory');
            $inventory->update({
                quantity => $inventory->get('quantity')
                    - $list->get('CartItem.quantity'),
            });
            return 1;
        });
    return;
}

sub _save_order {
    # Creates the order models using the current information.
    # Returns the realm_id for the new Order.
    my($self) = @_;
    my($cart) = $self->new_other('Cart')->load_from_cookie;
    my($order) = $self->new_other('Order')->create_realm(
        {
            cart_id => $cart->get('cart_id'),
            %{$self->get_model_properties('Order')},
        },
        {},
    );
    $self->req->with_realm(
        $order->get('order_id'),
        sub {
            $self->process_payment($self, {
                %{$self->get_model_properties('ECCreditCardPayment')},
                amount => $cart->get_total,
                service => b_use('Type.ECService')->ANIMAL,
            });
        });

    # create the entity address/phone for billing/shipping
    foreach my $location (qw(BILL_TO SHIP_TO)) {

        foreach my $model (qw(Address Phone)) {
            $self->new_other($model)->create({
                realm_id => $order->get('order_id'),
                location => $_L->from_name($location),
                %{$self->get_model_properties($model
                    . ($location eq 'BILL_TO' ? '' : '_2'))},
            });
        }
    }
    # grant the user access to view the order
    $self->new_other('RealmUser')->create({
        realm_id => $order->get('order_id'),
        user_id => $self->get_request->get('auth_user_id'),
        role => b_use('Auth.Role')->MEMBER,
    });
    _decrease_inventory($self);
    return $order;
}

1;
