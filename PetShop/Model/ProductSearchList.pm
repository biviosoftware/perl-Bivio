# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ProductSearchList;
use strict;
$Bivio::PetShop::Model::ProductSearchList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ProductSearchList::VERSION;

=head1 NAME

Bivio::PetShop::Model::ProductSearchList - search products by keywords

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ProductSearchList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::PetShop::Model::ProductSearchList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ProductSearchList>

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
	primary_key => [
	    ['Product.product_id'],
	],
	other => [
	    'Product.image_name',
	    'Product.description',
	],
	order_by => [
	    'Product.name',
	    'Product.product_id'
	],
#TODO: work-around for single table with search bug, needs a where clause
	where => ['Product.name', '=', 'Product.name'],
    };
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Uses the category search parameter to refine the query if present.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;

    my($where) = '';
    if ($query->get('search')) {
	# search for any word across name/description/category
	foreach my $word (split(' ', $query->get('search'))) {
	    $where .= ' OR ' unless $where eq '';
	    $where .= "LOWER(product_t.name ||' '|| product_t.description "
		."||' '|| product_t.category_id) LIKE ?";
	    push(@$params, "%$word%");
	}
    }
    return $where
	    ? "($where)"
	    # don't return anything unless where is specified
	    : 'product_t.name != product_t.name';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
