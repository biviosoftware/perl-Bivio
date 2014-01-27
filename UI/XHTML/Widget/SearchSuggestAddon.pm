# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SearchSuggestAddon;
use strict;
use Bivio::Base 'Widget.ControlBase';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SEARCH_LIST) = b_use('Agent.TaskId')->SEARCH_SUGGEST_LIST_JSON;
my($_GROUP_SEARCH_LIST) = b_use('Agent.TaskId')->GROUP_SEARCH_SUGGEST_LIST_JSON;
my($_JS) = b_use('HTMLWidget.JavaScript');

sub NEW_ARGS {
    return [qw(search_field_id)];
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($search_field_id) = $self->get('search_field_id');
    my($source_uri) = ${$self->render_attr('source_uri', $source)};
    $_JS->render($source, $buffer, undef, undef, <<"EOF");
\$("#$search_field_id").autocomplete({
  focus: function(event, ui) {
    return false;
  },
  source: "$source_uri",
  select: function(event, ui) {
    window.location = ui.item.value;
    return false;
  }
});
(function(\$) {
var proto = \$.ui.autocomplete.prototype;
\$.extend(proto, {
  _renderItem: function(ul, item) {
    return \$("<li></li>")
      .data("item.autocomplete", item)
      .append(\$("<a></a>")["html"](item.label))
      .appendTo(ul);
  }
});
})(jQuery);
EOF
    return;
}

sub initialize {
    my($self) = @_;
    $self->put(source_uri => [
	sub {
	    my($req) = shift->req;
	    return $req->format_stateless_uri({
		task_id => $req->get('auth_realm')->has_owner
		    ? $_GROUP_SEARCH_LIST : $_SEARCH_LIST,
	    });
	},
    ]);
    return;
}

1;
