# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchForm;
use strict;
use Bivio::Base 'Model.QuerySearchBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SEARCH) = b_use('SQL.ListQuery')->to_char('search');

sub execute_ok {
    my($self) = @_;
    my($query) = $self->req->unsafe_get('query') || {};

    if ($self->unsafe_get('search')) {
	$query->{$_SEARCH} = $self->get('search');
    }
    else {
	delete($query->{$_SEARCH});
    }
    $self->unsafe_get_context->put(query => $query);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
        visible => [
	    {
		name => 'search',
		type => 'Line',
		constraint => 'NONE',
		form_name => $_SEARCH,
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
