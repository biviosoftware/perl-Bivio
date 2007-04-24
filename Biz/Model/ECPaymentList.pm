# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPaymentList;
use strict;
$Bivio::Biz::Model::ECPaymentList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECPaymentList::VERSION;

=head1 NAME

Bivio::Biz::Model::ECPaymentList - list of payments information

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECPaymentList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::ECPaymentList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECPaymentList>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="format_name"></a>

=head2 format_name() : string

Formats the realm owner's name for this row
L<Bivio::Biz::Model::RealmOwner::format_name|Bivio::Biz::Model::RealmOwner/"format_name">.


=cut

sub format_name {
    my($self) = shift;
    return Bivio::Biz::Model::RealmOwner->format_name(
            $self, 'RealmOwner.', @_);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref


=cut

sub internal_initialize {
    return {
        version => 2,
	can_iterate => 1,
        primary_key => ['ECPayment.ec_payment_id'],
        auth_id => ['ECPayment.realm_id'],
        order_by => [qw(
            ECPayment.creation_date_time
            RealmOwner.name
            ECPayment.amount
            ECPayment.method
            ECPayment.status
            ECCreditCardPayment.processed_date_time
        )],
        other => [
            'RealmOwner.display_name',
            [qw(ECPayment.user_id RealmOwner.realm_id)],
	    [qw{ECPayment.ec_payment_id ECSubscription.ec_payment_id(+)}],
	    [qw{ECPayment.ec_payment_id ECCheckPayment.ec_payment_id(+)}],
	    [qw{ECPayment.ec_payment_id ECCreditCardPayment.ec_payment_id(+)}],
            qw(
            ECPayment.user_id
            ECPayment.description
            ECPayment.remark
            ECPayment.salesperson_id
            ECPayment.service
            ECPayment.point_of_sale
            ECSubscription.start_date
            ECSubscription.end_date
            ECSubscription.renewal_state
            ECCheckPayment.check_number
            ECCheckPayment.institution
            ECCreditCardPayment.processor_response
            ECCreditCardPayment.processor_transaction_number
            ECCreditCardPayment.card_expiration_date
            ECCreditCardPayment.card_name
            ECCreditCardPayment.card_zip
       )],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
