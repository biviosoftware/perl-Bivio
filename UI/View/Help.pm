# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Help;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub iframe {
    view_main(Page({
# Shouldn't this be xhtml => 1,
# Why can't this be inline?
	xhtml => 1,
	style => view_widget_value('xhtml_style'),
	head => Simple(''),
	body => Join([
	Join([<<"EOF"]),
<script>
window.onload=function(){
  parent.@{[HelpWiki()->RESIZE_FUNCTION]}();
}
</script>
EOF

	    HelpWiki(1),
	]),
	body_class => 'help_wiki_iframe_body',
    }));
    return;
}

1;
