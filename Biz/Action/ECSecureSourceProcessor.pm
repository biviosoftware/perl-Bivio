# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ECSecureSourceProcessor;
use strict;
use Bivio::Base 'Action.ECCreditCardProcessor';


sub internal_get_additional_form_data {
    # (self, proto, Model.ECPayment) : string
    my($proto, $payment) = @_;
    return $payment->req->with_realm($payment->get('user_id'), sub {
        my($user) = $payment->new_other('User')->load;
	my($address) = $payment->new_other('Address')->load;
	my($phone) = $payment->new_other('Phone')->load;
	return [
	    map([$_->[0] => b_use('Bivio::HTML')->escape_uri($_->[1])],
		[x_First_Name => $user->get('first_name')],
		[x_Last_Name => $user->get('last_name')],
		[x_Address => $address->get('street1')],
		[x_City => $address->get('city')],
		[x_State => $address->get('state')],
		[x_Country => $address->get('country')],
		[x_Phone => $phone->get('phone')],
		[x_Email => b_use('FacadeComponent.Text')
		     ->get_value('support_email', $payment->req)],
	    ),
	];
    });
}

1;
