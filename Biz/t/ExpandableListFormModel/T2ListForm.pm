# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ExpandableListFormModel::T2ListForm;
use strict;
use Bivio::Base 'Biz.ExpandableListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub EMPTY_AND_CANNOT_BE_SPECIFIED_FIELDS {
    return [qw(aux1 aux2)];
}

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(main)];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	list_class => 'NumberedList',
	version => 1,
	visible => [
	    {
		name => 'main',
	        type => 'Name',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	    {
		name => 'aux1',
	        type => 'Name',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	    {
		name => 'aux2',
	        type => 'Name',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
    });
}

1;
