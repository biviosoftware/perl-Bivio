# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPaymentListAll;
use strict;
$Bivio::Biz::Model::ECPaymentListAll::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECPaymentListAll::VERSION;

=head1 NAME

Bivio::Biz::Model::ECPaymentListAll - list of payments made

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECPaymentListAll;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::ECPaymentListAll::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECPaymentListAll>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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

Missing I<auth_id> because we need to be able to list all payments

=cut

sub internal_initialize {
    return {
        version => 1,
        primary_key => ['ECPayment.ec_payment_id'],
        order_by => [qw(
            ECPayment.creation_date_time
            RealmOwner.name
            RealmOwner_2.name
            ECPayment.payment_type
            ECPayment.amount
            ECPayment.method
            ECPayment.status
            ECPayment.processed_date_time
            ECPayment.transaction_id
        )],
        other => [
            [qw(ECPayment.realm_id RealmOwner.realm_id)],
            [qw(ECPayment.user_id RealmOwner_2.realm_id)],
            qw(
            ECPayment.ec_subscription_id
            ECPayment.ec_subscription_start_date
            ECPayment.ec_subscription_period
            ECPayment.processor_response
            ECPayment.credit_card_number
            ECPayment.credit_card_expiration_date
            ECPayment.credit_card_name
            ECPayment.credit_card_zip
            ECPayment.remark
       )],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
