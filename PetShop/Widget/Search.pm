# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Widget::Search;
use strict;
use Bivio::Agent::TaskId;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::UI::Font;

# C<Bivio::PetShop::Widget::Search> simple search form.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    # (self) : undef
    # Does nothing.  Widget is entirely dynamic.
    return;
}

sub render {
    # (self, any, string_ref) : undef
    # Render the input field.
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;

    my($field_prefix, $field_suffix) = Bivio::UI::Font->format_html(
	    'input_field', $req);

#TODO: This should use a SearchForm.  There's no need to inline, e.g.
#      Form('SearchForm', Join(['<br>', Text('search'), ' ',
#             FormButton('search')]), {method => 'GET'})
#      SearchForm needs to set the html name to ListQuery->to_char.
    $$buffer .= '<br><form method=get action="'
	    .$req->format_stateless_uri(Bivio::Agent::TaskId->ITEM_SEARCH)
	    .'">'
	    .$field_prefix
	    .'<input type=text size=14 name='
	    .Bivio::SQL::ListQuery->to_char('search')
	    .'>'
	    .$field_suffix
	    .' '
	    .'<input type=image border=0 alt="Search" '
		    .'src="/i/search.gif">'
	    .'</form>';
    return;
}

1;
