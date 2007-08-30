# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Help;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub iframe {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts('Bivio::UI::XHTML::ViewShortcuts');
    view_main(Page({
	head => Join([<<'EOF']),
<script>
window.onload=function(){
  parent.resize_help_popup();
}
</script>
EOF
	style => Join([
	    view_widget_value('xhtml_style'),
	    <<'EOF',
<style type="text/css">
<!--
body {
  margin: 0;
  min-width: 0;
  font-size: smaller;
}
-->
</style>
EOF
	]),
	body => HelpWiki({
	    show_help_box => 1,
	}),
    }));
    return;
}

1;
