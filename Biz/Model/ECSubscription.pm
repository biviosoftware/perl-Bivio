# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECSubscription;
use strict;
$Bivio::Biz::Model::ECSubscription::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECSubscription::VERSION;

=head1 NAME

Bivio::Biz::Model::ECSubscription - a subscription to a service

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

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref


=cut

sub internal_initialize {
    return {
        version => 1,
        table_name => 'ec_subscription_t',
        columns => {
            ec_subscription_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            subscription_type => ['ECSubscription', 'NOT_ZERO_ENUM'],
            start_date_time => ['DateTime', 'NOT_NULL'],
            end_date => ['Date', 'NOT_NULL'],
            renewal_method => ['ECRenewalMethod', 'NOT_ZERO_ENUM'],
            renewal_period => ['DateInterval', 'NOT_NULL'],
        },
        auth_id => 'realm_id',
    };
}

=for html <a name="is_running"></a>

=head2 is_running() : boolean

Returns TRUE if this subscription is currently running, ie. not expired.

=cut

sub is_running {
    my($self) = @_;
    return Bivio::Type::Date->compare(Bivio::Type::Date->now,
            $self->get('end_date')) == 1 ? 0 : 1;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
