# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::OrderStatus;
use strict;
$Bivio::PetShop::Model::OrderStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::OrderStatus::VERSION;

=head1 NAME

Bivio::PetShop::Model::OrderStatus - order status

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::OrderStatus;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::OrderStatus::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::OrderStatus>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'order_status_t',
	columns => {
            order_id => ['Order.order_id', 'PRIMARY_KEY'],
	    user_id => ['UserAccount.user_id', 'NOT_NULL'],
	    time_stamp => ['Date', 'NOT_NULL'],
	    status => ['OrderStatus', 'NOT_NULL'],
	},
	auth_id => 'user_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
