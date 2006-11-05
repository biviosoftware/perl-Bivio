# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::BasicPage;
use strict;
use base 'Bivio::UI::HTML::Widget::Page';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    my($proto, $attrs) = @_;
    view_declare(qw(page_title));
    view_put(map(
	("basic_page_$_->[0]" => delete($attrs->{$_->[0]}) || $_->[1] || Join([''])),
	[title => vs_text(
	    [sub {"page.title.$_[1]"}, ['task_id', '->get_name']])],
	['meta_info'],
	['content'],
	[style => StyleSheet('/f/base.css')],
	['script'],
    ));
    return $proto->SUPER::new($attrs)->put_unless_exists(
	head => Join([
	    Title([vs_site_name(), view_widget_value('basic_page_title')]),
	    view_widget_value('basic_page_meta_info'),
	    view_widget_value('basic_page_script'),
	]),
	body => view_widget_value('basic_page_content'),
	style => view_widget_value('basic_page_style'),
	xhtml => 1,
    );
}

1;
