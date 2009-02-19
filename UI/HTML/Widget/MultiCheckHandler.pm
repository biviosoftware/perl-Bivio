# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::MultiCheckHandler;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_html_field_attributes {
    return ' onclick="mc_checked(this, event)"';
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= b_use('HTMLWidget.JavaScript')->strip(<<'EOF');
<script type="text/javascript">
var mc_last_check = -1;
function mc_checked(c, e) {
  var index = parseInt(c.name.substr(c.name.indexOf('_') + 1));

  if (e.shiftKey && mc_last_check != -1) {

    for (var i = (mc_last_check < index ? mc_last_check : index);
      i <= (mc_last_check > index ? mc_last_check : index); i++) {
      if (i != index)
        c.form[c.name.substr(0, c.name.indexOf('_') + 1) + i].checked = c.checked;
    }
  }
  mc_last_check = index;
  return;
}
</script>
EOF
    return;
}

1;
