# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotChoiceSelectList;
use strict;
use Bivio::Base 'Model.TupleSlotChoiceList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub EMPTY_KEY_VALUE {
    return 'Select Value';
}

sub internal_initialize {
    return {
        version => 1,
	primary_key => [{
	    name => 'choice',
	    type => 'TupleSlot',
	    constraint => 'NONE',
	}],
    };
}

sub internal_load_rows {
    my($self) = shift;
    return [
	{choice => $self->EMPTY_KEY_VALUE},
	map(+{choice => $_->{choice}},
	    @{$self->SUPER::internal_load_rows(@_)}),
    ];
}

1;
