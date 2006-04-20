# Copyright (c) 2006 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListFormModel::T1ListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty_row {
    my($self) = @_;
    $self->internal_load_field('form_index', 'index');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	list_class => 'NumberedList',
	version => 1,
	visible => [
	    {
		name => 'form_index',
	        type => 'Integer',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
    });
}

1;
