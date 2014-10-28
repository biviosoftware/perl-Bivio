# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::CopyListValueHandler;
use strict;
use Bivio::Base 'UI.Widget';
my($_JS) = b_use('HTMLWidget.JavaScript');


sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onfocus="cr_focus(this)"';
}

sub render {
    my($self, $source, $buffer) = @_;
    $_JS->render($source, $buffer, $self->package_name, <<'EOF');
function cr_focus(c) {
  if (c.value)
    return;
  var match = ner_match_name(c.name);
  var prev = document.getElementsByName(match[1] + (parseInt(match[2]) - 1));
  if (prev.length)
    c.value = prev[0].value;
  return;
}
EOF
    return;
}

1;
