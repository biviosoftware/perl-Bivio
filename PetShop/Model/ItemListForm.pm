# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ItemListForm;
use strict;
$Bivio::PetShop::Model::ItemListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ItemListForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::ItemListForm - add a list item to the cart

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ItemListForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::PetShop::Model::ItemListForm::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ItemListForm>

=cut

#=IMPORTS
use Bivio::PetShop::Model::ItemForm;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_ok_row"></a>

=head2 execute_ok_row()

Adds the current row to the cart if the add_to_cart button was selected.

=cut

sub execute_ok_row {
    my($self) = @_;
    if ($self->get('add_to_cart')) {
	Bivio::PetShop::Model::ItemForm->add_item_to_cart(
		$self->get_list_model->get_model('Item'));
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	list_class => 'ItemList',
	visible => [
	    {
		name => 'add_to_cart',
		constraint => 'NONE',
		type => 'OKButton',
		in_list => 1,
	    },
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
