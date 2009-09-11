# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FormMode;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile_with_numbers([qw(EDIT CREATE)]);

sub setup_by_list_this {
    my($proto, $list, $detail_name) = @_;
    my($q) = $list->parse_query_from_request;
    my($self) = $proto->from_name(
	$q->get('this') && $list->unsafe_load_this($q)
	    ? ('EDIT', $list->get_model($detail_name))[0] : 'CREATE',
    );
    $self->execute($list->get_request);
    return $self;
}

1;
