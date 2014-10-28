# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::MultiCheckHandler;
use strict;
use Bivio::Base 'UI.Widget';

my($_JS) = b_use('HTMLWidget.JavaScript');

sub get_html_field_attributes {
    return ' onclick="mc_checked(this, event)"';
}

sub render {
    my($self, $source, $buffer) = @_;
    $_JS->render($source, $buffer, $self->package_name, <<'EOF');
var mc_last_check = -1;
function mc_checked(c, e) {
  var index = parseInt(c.name.substr(c.name.lastIndexOf('_') + 1));

  if (e.shiftKey && mc_last_check != -1) {
    for (var i = (mc_last_check < index ? mc_last_check : index);
      i <= (mc_last_check > index ? mc_last_check : index); i++) {

      if (i != index) {
        var field = c.name.substr(0, c.name.lastIndexOf('_') + 1) + i;
        if (c.form[field])
          c.form[field].checked = c.checked;
      }
    }
  }
  mc_last_check = index;
  return;
}
EOF
    return;
}

1;
