# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotChoiceSelectList;
use strict;
use base 'Bivio::Biz::Model::TupleSlotChoiceList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub EMPTY_KEY_VALUE {
    return 'Select Value';
}

sub internal_load {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_load(@_);
    my($rows) = $self->internal_get_rows;
    unshift(
	@$rows,
	{
	    map(($_ => undef), @{$self->get_keys}),
	    value => $self->EMPTY_KEY_VALUE,
	},
    ) if @$rows;
    return @res;
}

1;
