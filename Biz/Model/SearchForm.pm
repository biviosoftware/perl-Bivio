# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    shift->internal_stay_on_page;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'search',
		type => 'Line',
		constraint => 'NONE',
		form_name => Bivio::SQL::ListQuery->to_char('search'),
	    },
	],
    });
}

sub put_search_value {
    my($self, $value) = @_;
    $self->internal_put_field(search => $value);
    return;
}

1;
