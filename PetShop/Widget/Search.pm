# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Widget::Search;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('value');
    $self->put(value => FORM(Join([
	BR(),
	INPUT({
	    TYPE => 'text',
	    SIZE => 20,
	    NAME => b_use('SQL.ListQuery')->to_char('search'),
	}),
	vs_blank_cell(),
	INPUT({
	    TYPE => 'submit',
	    CLASS => 'submit',
	    VALUE => 'Search',
	}),
    ]), {
	METHOD => 'get',
	ACTION => ['->format_uri', 'ITEM_SEARCH'],
    }));
    return shift->SUPER::initialize(@_);
}

1;
