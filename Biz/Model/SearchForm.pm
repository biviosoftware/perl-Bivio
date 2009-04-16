# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CLEAR_ON_FOCUS_HINT {
    return 'Search';
}

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(search => $self->CLEAR_ON_FOCUS_HINT)
	unless defined($self->unsafe_get('search'));
    return;
}

sub execute_ok {
    shift->internal_stay_on_page;
    return;
}

sub get_search_value {
    my($self) = @_;
    my($s) = $self->unsafe_get('search');
    return ($s || '') eq $self->CLEAR_ON_FOCUS_HINT ? undef : $s;
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
		form_name => b_use('SQL.ListQuery')->to_char('search'),
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
