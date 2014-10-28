# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchSuggestList;
use strict;
use Bivio::Base 'Model.SearchList';
b_use('IO.ClassLoaderAUTOLOAD');


sub PAGE_SIZE {
    return 10;
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($q) = $self->ureq('query');
    $query->put(search => $q->{term})
	if $q && defined($q->{term});
    return shift->SUPER::internal_load_rows(@_);
}

1;
