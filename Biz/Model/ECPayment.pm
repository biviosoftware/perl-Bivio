# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPayment;
use strict;
$Bivio::Biz::Model::ECPayment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECPayment::VERSION;

=head1 NAME

Bivio::Biz::Model::ECPayment - handle payments for premium services

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECPayment;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ECPayment::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECPayment>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref


=cut

sub internal_initialize {
    return {
        version => 1,
        table_name => 'ec_payment_t',
        columns => {
            ec_payment_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            payment_type => ['ECPayment', 'NOT_ZERO_ENUM'],
            amount => ['Amount', 'NOT_NULL'],
            method => ['ECPaymentMethod', 'NOT_ZERO_ENUM'],
            ec_subscription_id => ['PrimaryId', 'NONE'],
            ec_subscription_start_date => ['Date', 'NONE'],
            ec_subscription_period => ['DateInterval', 'NONE'],
            status => ['ECPaymentStatus', 'NOT_NULL'],
            processed_date_time => ['DateTime', 'NONE'],
            processor_response => ['Text', 'NONE'],
            credit_card_number => ['CreditCardNumber', 'NONE'],
            credit_card_expiration_date => ['Date', 'NONE'],
            credit_card_name => ['Line', 'NONE'],
            credit_card_zip => ['Name', 'NONE'],
            remark => ['Text', 'NONE'],
        },
        auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
