# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::ItemSearchList;
use strict;
$Bivio::PetShop::Model::ItemSearchList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ItemSearchList::VERSION;

=head1 NAME

Bivio::PetShop::Model::ItemSearchList - search items by keywords

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ItemSearchList;

=cut

=head1 EXTENDS

L<Bivio::PetShop::Model::ItemList>

=cut

use Bivio::PetShop::Model::ItemList;
@Bivio::PetShop::Model::ItemSearchList::ISA = ('Bivio::PetShop::Model::ItemList');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ItemSearchList> produces a list of items to found by
keyword.

=cut

=head1 CONSTANTS

=cut

=for html <a name="PAGE_SIZE"></a>

=head2 PAGE_SIZE : int

Returns a low number so we can demonstrate paging on search page.

=cut

sub PAGE_SIZE {
    return 8;
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($parent_info) = $self->SUPER::internal_initialize;
    delete($parent_info->{parent_id});
    return $self->merge_initialize_info($parent_info, {
	other => [
	    'Product.category_id',
	],
    });
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Uses the category search parameter to refine the query if present.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;

    my($where) = '';
    # search for any word across name/description/category
    foreach my $word (split(' ', $query->get('search') || '')) {
	$where .= ' AND '
	    if $where;
	$where .= '(' . join(" || ' ' || ", map({"LOWER($_)"} qw(
            item_t.attr1
            product_t.name
            product_t.description
            product_t.category_id
        ))) . ') LIKE ?';
	push(@$params, lc("%$word%"));
    }
    return $where && "($where)";
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
