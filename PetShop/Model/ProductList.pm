# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ProductList;
use strict;
$Bivio::PetShop::Model::ProductList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ProductList::VERSION;

=head1 NAME

Bivio::PetShop::Model::ProductList - list of products by category

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ProductList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::PetShop::Model::ProductList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ProductList>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,

	# List of fields which uniquely identify each row in this list
	primary_key => [
	    ['Product.product_id'],
	],

	# Allow sorting by name and product_id
	order_by => [
	    'Product.name',
	    'Product.product_id'
	],

	# Narrows query to just this category_id; selectable by ListQuery
	parent_id => ['Product.category_id'],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
