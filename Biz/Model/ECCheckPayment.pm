# Copyright (c) 2002-2019 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::ECCheckPayment;
use strict;
use Bivio::Base 'Biz.PropertyModel';

sub create {
    my($self, $new_values) = @_;
    $new_values->{realm_id} ||= $self->get_request->get('auth_id');
    return $self->SUPER::create($new_values);
}

sub internal_initialize {
    # none of the related fields are linked here
    # need to always preserve ECPayments, so deleting them
    # via cascade_delete() should always fail
    return {
	version => 1,
	table_name => 'ec_check_payment_t',
	columns => {
	    ec_payment_id => ['ECPayment.ec_payment_id', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    check_number => ['Line', 'NOT_NULL'],
	    institution => ['Line', 'NONE'],
        },
	auth_id => 'realm_id',
	other => [['ec_payment_id', 'ECPayment.ec_payment_id']],
    };
}

1;
