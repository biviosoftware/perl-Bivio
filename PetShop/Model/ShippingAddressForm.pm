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
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	require_context => 1,
	version => 1,
	visible => [
  	    'Order.ship_to_name',
  	    'Address_2.street1',
  	    'Address_2.street2',
  	    'Address_2.city',
  	    'Address_2.state',
  	    'Address_2.zip',
  	    'Address_2.country',
  	    'Phone_2.phone',
	],
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
