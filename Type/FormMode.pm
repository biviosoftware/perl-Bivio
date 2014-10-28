# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FormMode;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile_with_numbers([qw(EDIT CREATE)]);

sub setup_by_list_this {
    my($proto, $list, $detail_name) = @_;
    my($self) = $proto->from_name(
	$list->unsafe_load_this($list->parse_query_from_request)
	    ? ('EDIT', $list->get_model($detail_name))[0] : 'CREATE',
    );
    $self->execute($list->req);
    return $self;
}

1;
