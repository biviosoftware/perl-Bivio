# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SearchSuggestAddon;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');


sub initialize {
    my($self) = @_;
    $self->put_unless_exists(values => [
	LocalFileAggregator({
	    widget_values => [
		'jquery-ui/jquery-ui.min.css',
	    ],
	}),
	LocalFileAggregator({
	    widget_values => [
		'jquery-ui/jquery-ui.min.js',
	    ],
	}),
	LocalFileAggregator({
	    widget_values => [
		InlineJavaScript(Join([
		    <<'EOF',
(function($, search_field_id, source_uri) {
$("#" + search_field_id).autocomplete({
  focus: function(event, ui) {
    return false;
  },
  position: {
    my: "right top",
    at: "right bottom",
    collision: "flipfit none",
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
  },
  _renderMenu: function(ul, items) {
    var that = this;
    $.each(items, function(index, item) {
      that._renderItemData(ul, item);
    });
    $(ul).addClass("dropdown-menu");
  },
  _resizeMenu: function() {
    this.menu.element.outerWidth(
      Math.min(738, $(window).width() - 30)
    );
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
		])),
	    ],
	}),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $search_field_id, $attributes) = @_;
    return {
	search_field_id => $search_field_id,
	($attributes ? %$attributes: ()),
    };
}

1;
