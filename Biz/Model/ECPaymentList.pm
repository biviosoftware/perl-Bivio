# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPaymentList;
use strict;
$Bivio::Biz::Model::ECPaymentList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECPaymentList::VERSION;

=head1 NAME

Bivio::Biz::Model::ECPaymentList - list of payments made

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


=cut

sub internal_initialize {
    return {
        version => 1,
        primary_key => ['ECPayment.ec_payment_id'],
        auth_id => ['ECPayment.realm_id'],
        order_by => [qw(
            ECPayment.creation_date_time
            RealmOwner.name
            ECPayment.payment_type
            ECPayment.amount
            ECPayment.method
            ECPayment.status
            ECPayment.processed_date_time
        )],
        other => [
            [qw(ECPayment.user_id RealmOwner.realm_id)],
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
