# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECAdmPaymentList;
use strict;
$Bivio::Biz::Model::ECAdmPaymentList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECAdmPaymentList::VERSION;

=head1 NAME

Bivio::Biz::Model::ECAdmPaymentList - list of payments made

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECAdmPaymentList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::ECAdmPaymentList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECAdmPaymentList>

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

=for html <a name="format_uri_hack"></a>

=head2 format_uri_hack() : string

#TODO: This is a HACK!!!  But need to have detail uri formatted for each realm.

=cut

sub format_uri_hack {
    my($self) = @_;
    return $self->get_request->format_uri(
	    Bivio::Agent::TaskId::ADM_EC_SUBSCRIPTION_EDIT(), {
		p => $self->get('ECPayment.ec_payment_id'),
		realm => $self->get('RealmOwner.name'),
	    });
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
            ECPayment.processor_transaction_number
            ECPayment.ec_subscription_start_date
            ECPayment.ec_subscription_period
            ECPayment.processor_response
        )],
        other => [
            [qw(ECPayment.realm_id RealmOwner.realm_id)],
            [qw(ECPayment.user_id RealmOwner_2.realm_id)],
            [qw{ECPayment.ec_subscription_id
                       ECSubscription.ec_subscription_id(+)}],
	    {
		name => 'description_and_remark',
		type => 'Bivio::Type::Text',
		constraint => 'NOT_NULL',
	    },
            qw(
            ECPayment.credit_card_number
            ECPayment.credit_card_expiration_date
            ECPayment.credit_card_name
            ECPayment.credit_card_zip
            ECPayment.description
            ECPayment.remark
       )],
    };
}

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row(hash_ref row)

Creates description_and_remark.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{description_and_remark} = $row->{'ECPayment.description'}
	    .(defined($row->{'ECPayment.remark'})
		    ? "\n".$row->{'ECPayment.remark'} : '');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
