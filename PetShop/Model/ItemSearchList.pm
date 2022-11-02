# Copyright (c) 2002-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::ItemSearchList;
use strict;
use Bivio::Base 'Model.ItemList';

# ItemSearchList produces a list of items to found by keyword.


sub PAGE_SIZE {
    # Returns a low number so we can demonstrate paging on search page.
    return 8;
}

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

sub internal_pre_load {
    # Uses the category search parameter to refine the query if present.
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

1;
