# Copyright (c) 2000-2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPayment;
use strict;
$Bivio::Biz::Model::ECPayment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECPayment::VERSION;

=head1 NAME

Bivio::Biz::Model::ECPayment - payments for services

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECPayment;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ECPayment::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

<Bivio::Biz::Model::ECPayment> payment information

=cut

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : Bivio::Biz::Model::ECPayment

Creates a payment record. Uses defaults for realm_id, user_id and
creation_date_time and description.

=cut

sub create {
    my($self, $new_values) = @_;
    my($req) = $self->get_request;
    $new_values->{realm_id} ||= $req->get('auth_id');
    $new_values->{user_id} ||= $req->get('auth_user_id');
    $new_values->{creation_date_time} ||= Bivio::Type::DateTime->now;
    $new_values->{description} = $new_values->{service}->get_short_desc
	unless defined($new_values->{description});
    return $self->SUPER::create($new_values);
}

=for html <a name="get_amount_sum"></a>

=head2 get_amount_sum() : string

Returns the sum of all payments in this realm.  Returns 0 if no payments
for this realm.

=cut

sub get_amount_sum {
    my($self) = @_;
    return (Bivio::SQL::Connection->execute_one_row(
	'SELECT SUM(amount)
         FROM ec_payment_t
         WHERE realm_id = ?',
	[$self->get_request->get('auth_id')])
	|| [0])->[0];
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
        table_name => 'ec_payment_t',
        columns => {
            ec_payment_id => ['PrimaryId', 'PRIMARY_KEY'],
	    # Which realm is using the service
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    # Which realm paid for the service
            user_id => ['PrimaryId', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            amount => ['Amount', 'NOT_NULL'],
            method => ['ECPaymentMethod', 'NOT_ZERO_ENUM'],
            status => ['ECPaymentStatus', 'NOT_NULL'],
	    description => ['Line', 'NOT_NULL'],
            remark => ['Text', 'NONE'],
	    salesperson_id => ['PrimaryId', 'NONE'],
	    service => ['ECService', 'NOT_NULL'],
	    point_of_sale => ['ECPointOfSale', 'NOT_NULL'],
        },
        auth_id => 'realm_id',
    };
}

=for html <a name="unsafe_get_model"></a>

=head2 unsafe_get_model(string name) : Bivio::Biz::PropertyModel

Overridden to support getting the related ECSubscription,
ECCheckPayment or ECCreditCardPayment.

=cut

sub unsafe_get_model {
    my($self, $name) = @_;

    if ($name eq 'ECSubscription' || $name eq 'ECCheckPayment'
	|| $name eq 'ECCreditCardPayment') {

	my($model) =  Bivio::Biz::Model->new($self->get_request, $name);
	return $model->unauth_load({
	    ec_payment_id => $self->get('ec_payment_id')})
	    ? $model
	    : undef;
    }
    return $self->SUPER::unsafe_get_model($name);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000-2002 bivio Software Artisans, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
