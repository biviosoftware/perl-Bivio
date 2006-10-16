# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECSubscription;
use strict;
$Bivio::Biz::Model::ECSubscription::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECSubscription::VERSION;

=head1 NAME

Bivio::Biz::Model::ECSubscription - a subscription to a service

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECSubscription;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ECSubscription::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECSubscription> holds data about a particular
service subscription. The subscription can be running or expired, depending
on its end date.

=cut


=head1 CONSTANTS

=cut

=for html <a name="INFINITE_END_DATE"></a>

=head2 INFINITE_END_DATE : string

End of infinite free trial.

=cut

my($_INFINITE_END_DATE);
sub INFINITE_END_DATE {
    # Needs to be a bit less than max for the software to work
    return $_INFINITE_END_DATE
	||= Bivio::Type::Date ->add_days(Bivio::Type::Date->get_max, -366);
}

#=IMPORTS
use Bivio::Type::Date;
use Bivio::Type::ECRenewalState;

#=VARIABLES
my($_D) = 'Bivio::Type::Date';

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref values) : self

Creates a subscription model, sets default values.

=cut

sub create {
    my($self, $values) = @_;
    $values->{realm_id} ||= $self->get_request->get('auth_id');
    $values->{renewal_state} ||= Bivio::Type::ECRenewalState->OK;
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
        version => 1,
        table_name => 'ec_subscription_t',
        columns => {
	    ec_payment_id => ['ECPayment.ec_payment_id', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
            start_date => ['Date', 'NOT_NULL'],
            end_date => ['Date', 'NOT_NULL'],
	    renewal_state => ['ECRenewalState', 'NOT_ZERO_ENUM'],
        },
        auth_id => 'realm_id',
	other => [['ec_payment_id', 'ECPayment.ec_payment_id']],
    };
}

=for html <a name="is_infinite"></a>

=head2 is_infinite() : boolean

Returns true if the subscription is infinite.

=cut

sub is_infinite {
    my($self) = @_;
    return $self->get('end_date') eq $self->INFINITE_END_DATE ? 1 : 0;
}

=for html <a name="make_infinite"></a>

=head2 make_infinite() : self

Updates to an infinite subscription.

=cut

sub make_infinite {
    my($self) = @_;
    return $self->update({end_date => $self->INFINITE_END_DATE});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
