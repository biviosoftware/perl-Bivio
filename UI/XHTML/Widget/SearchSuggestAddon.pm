# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SearchSuggestAddon;
use strict;
use Bivio::Base 'HTMLWidget.InlineJavaScript';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(search_field_id)];
}

sub initialize {
    my($self, $source) = @_;
    $self->initialize_attr(
	value => Join([
	    <<'EOF',
(function($, search_field_id, source_uri) {
$("#" + search_field_id).autocomplete({
  focus: function(event, ui) {
    return false;
  },
  source: source_uri,
  select: function(event, ui) {
    window.location = ui.item.value;
    return false;
  }
});
var proto = $.ui.autocomplete.prototype;
$.extend(proto, {
  _renderItem: function(ul, item) {
    return $("<li></li>")
      .data("item.autocomplete", item)
      .append($("<a></a>")["html"](item.label))
      .appendTo(ul);
  }
});
})(jQuery,
EOF
	    JavaScriptString($self->get('search_field_id')),
	    ',',
	    JavaScriptString(
		URI({
		    task_id => [sub {
			return shift->req('auth_realm')->has_owner
			    ? 'GROUP_SEARCH_SUGGEST_LIST_JSON'
			    : 'SEARCH_SUGGEST_LIST_JSON';
		    }],
		}),
	    ),
	    ");\n",
	]),
	$source,
    );
    return shift->SUPER::initialize(@_);
}

1;
