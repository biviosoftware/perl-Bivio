# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ShippingAddressForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    # Saves all fields into the order form context.
    my($self) = @_;
    # copy the current values into the OrderForm context
    $self->put_context_fields(%{$self->internal_get});
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	require_context => 1,
	version => 1,
	visible => [
  	    'Order.ship_to_name',
  	    'Address_2.street1',
  	    'Address_2.street2',
  	    'Address_2.city',
  	    'Address_2.state',
  	    'Address_2.zip',
  	    'Address_2.country',
  	    'Phone_2.phone',
	],
    });
}

1;
