# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::NewEmptyRowHandler;
use strict;
use Bivio::Base 'UI.Widget';

my($_JS) = b_use('HTMLWidget.JavaScript');

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onfocus="ner_focus(this, \''
        . $source->req('form_model')
            ->get_field_name_for_html('empty_row_count')
        . '\')"';
}

sub render {
    my($self, $source, $buffer) = @_;
    $_JS->render($source, $buffer, $self->package_name, <<'EOF');
function ner_match_name(n) {
  return new RegExp("(.+\\_)(\\d+)$").exec(n);
}

function ner_next_name(n) {
  var match = ner_match_name(n);
  return match
    ? (match[1] + (parseInt(match[2]) + 1))
    : null;
}

function ner_rename_children(c) {
  if (c.name)
    c.name = ner_next_name(c.name);
  else {
    for (var i = 0; i < c.childNodes.length; i++)
      ner_rename_children(c.childNodes[i]);
  }
  return c;
}

function ner_add_hidden(c) {
  var count = parseInt(ner_match_name(c.name)[2]);

  for (var i = 0; i < c.form.childNodes.length; i++) {
    var child = c.form.childNodes[i];

    if (child.type && child.type == "hidden") {
        var match = ner_match_name(child.name);
        if (match && parseInt(match[2]) == count)
            c.form.appendChild(ner_rename_children(child.cloneNode(true)));
    }
  }
}

function ner_focus(c, empty_row_count) {
  var n = ner_next_name(c.name);
  if (! n || document.getElementsByName(n).length)
    return;
  var tr = c.parentNode.parentNode;
  tr.parentNode.appendChild(ner_rename_children(tr.cloneNode(true)));
  var f = document.getElementsByName(empty_row_count)[0];
  f.value = parseInt(f.value) + 1;
  ner_add_hidden(c);
}
EOF
    return;
}

1;
