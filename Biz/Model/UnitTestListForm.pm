# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnitTestListForm;
use strict;
use Bivio::Base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty_row {
    my($self) = @_;
    my($m) = $self->get_list_model;
    $self->internal_put_field(concat => join('!', $m->get(qw(letters index))));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'UnitTestList',
	visible => [
	    {
		name => 'concat',
		type => 'Name',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
    });
}

sub internal_initialize_list {
    my($self) = @_;
    $self->new_other('UnitTestList')->load_page({count => 3});
    return shift->SUPER::internal_initialize_list(@_);
}

1;
