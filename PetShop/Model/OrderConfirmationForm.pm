# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::OrderConfirmationForm;
use strict;
$Bivio::PetShop::Model::OrderConfirmationForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::OrderConfirmationForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::OrderConfirmationForm - order confirmation sub form

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::OrderConfirmationForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::OrderConfirmationForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::OrderConfirmationForm>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves the 'confirmed' state into the order context.

=cut

sub execute_ok {
    my($self) = @_;
    $self->put_context_fields(confirmed_order => 1);
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
