# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SearchForm;
use strict;
use Bivio::Base 'XHTMLWidget.Form';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SEARCH_LIST) = b_use('Agent.TaskId')->SEARCH_LIST;
my($_GROUP_SEARCH_LIST) = b_use('Agent.TaskId')->GROUP_SEARCH_LIST;

sub initialize {
    my($self) = @_;
    $self->map_invoke(put_unless_exists => [
	[action => [sub {
	    my($req) = shift->req;
	    return $req->format_stateless_uri({
		task_id => $req->get('auth_realm')->has_owner
		    ? $_GROUP_SEARCH_LIST : $_SEARCH_LIST,
	    });
	}]],
	[form_class => 'SearchForm'],
	[want_hidden_fields => 0],
	[form_method => 'GET'],
	[value => sub {
	     return Join([
		 ClearOnFocus(
		     Text({
			 field => 'search',
			 size => $self->get_or_default(text_size => 30),
		     }),
		     b_use('Model.' . $self->get('form_class'))
			 ->CLEAR_ON_FOCUS_HINT,
		 ),
		 $self->get_or_default(image_form_button =>
		     ImageFormButton(qw(ok_button magnifier go))),
		 DIV_b_realm_only(
		     Checkbox({
			 field => 'b_realm_only',
			 label => Prose(vs_text(qw(SearchForm b_realm_only))),
			 control => [[qw(->req auth_realm)], '->has_owner'],
		     }),
		 ),
	     ]);
	}],
	[class => 'search'],
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    # Implements positional argument parsing for L<new|"new">.
    return shift->internal_compute_new_args([qw(value href ?class)], \@_);
}

1;
