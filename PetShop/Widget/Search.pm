# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Widget::Search;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('FacadeComponent.Font');
my($_ITEM_SEARCH) = b_use('Agent.TaskId')->ITEM_SEARCH;

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($field_prefix, $field_suffix) = $_F->format_html('input_field', $req);
    $$buffer .= '<br /><form method="get" action="'
	    .$req->format_stateless_uri($_ITEM_SEARCH)
	    .'">'
	    .$field_prefix
	    .'<input type="text" size="14" class="b_align_e" id="'
	    .Bivio::SQL::ListQuery->to_char('search')
	    .'" />'
	    .$field_suffix
	    .' '
	    .'<input type="image" alt="Search" class="b_align_w"'
		    .'src="/i/search.gif" />'
	    .'</form>';
    return;
}

1;
