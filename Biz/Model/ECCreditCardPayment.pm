# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ECCreditCardPayment;
use strict;
$Bivio::Biz::Model::ECCreditCardPayment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECCreditCardPayment::VERSION;

=head1 NAME

Bivio::Biz::Model::ECCreditCardPayment - credit card payment info

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECCreditCardPayment;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ECCreditCardPayment::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECCreditCardPayment>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : Model.ECCreditCardPayment

Creates a new credit card payment record. Defaults the realm_id.

=cut

sub create {
    my($self, $new_values) = @_;
    $new_values->{realm_id} ||= $self->get_request->get('auth_id');
    return $self->SUPER::create($new_values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {

    # none of the related fields are linked here
    # need to always preserve ECPayments, so deleting them
    # via cascade_delete() should always fail

    return {
	version => 1,
	table_name => 'ec_credit_card_payment_t',
	columns => {
	    ec_payment_id => ['ECPayment.ec_payment_id', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            processed_date_time => ['DateTime', 'NONE'],
            processor_response => ['Text', 'NONE'],
            processor_transaction_number => ['Name', 'NONE'],
            card_number => ['CreditCardNumber', 'NONE'],
            card_expiration_date => ['Date', 'NONE'],
            card_name => ['Line', 'NONE'],
            card_zip => ['Name', 'NONE'],
        },
	auth_id => 'realm_id',
	other => [['ec_payment_id', 'ECPayment.ec_payment_id']],
    };
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
