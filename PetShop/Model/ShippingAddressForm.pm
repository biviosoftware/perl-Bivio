# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ShippingAddressForm;
use strict;
$Bivio::PetShop::Model::ShippingAddressForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ShippingAddressForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::ShippingAddressForm - shipping address sub form

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ShippingAddressForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::ShippingAddressForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ShippingAddressForm>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves all fields into the order form context.

=cut

sub execute_ok {
    my($self) = @_;

    # copy the current values into the OrderForm context
    $self->put_context_fields(%{$self->internal_get});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	require_context => 1,
	version => 1,
	visible => [
	    'Order.ship_to_first_name',
	    'Order.ship_to_last_name',
	    'EntityAddress_2.addr1',
	    'EntityAddress_2.addr2',
	    'EntityAddress_2.city',
	    'EntityAddress_2.state',
	    'EntityAddress_2.zip',
	    'EntityAddress_2.country',
	    'EntityPhone_2.phone',
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
