# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Page3;
use strict;
use base 'Bivio::UI::HTML::Widget::Page';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    my($proto, $attrs) = @_;
    view_declare(qw(page3_title));
    view_put(map(
	("page3_$_->[0]" => delete($attrs->{$_->[0]}) || $_->[1] || Join([''])),
	[title => Prose(vs_text(
	    [sub {"page3.title.$_[1]"}, ['task_id', '->get_name']]))],
	['meta_info'],
#TODO: Move this all to Base.bview.  Doesn't belong here
	[head1 => Link(SPAN(), 'SITE_ROOT')],
	[head2 => DIV_title(Prose(view_widget_value('page3_title')))],
	['head3'],
	['content'],
	[foot1 => Link(String('back to top'), '#top')],
	['foot2'],
	[foot3 => vs_text_as_prose('xhtml_copyright')],
	[style => StyleSheet('/f/base.css')],
    ));
    return $proto->SUPER::new($attrs)->put_unless_exists(
	head => Join([
	    Title([vs_site_name(), Prose(view_widget_value('page3_title'))]),
	    view_widget_value('page3_meta_info'),
	]),
	body => Join([
	    '<a name="top"></a>',
	    DIV_head(Join([
		map(
		    DIV(view_widget_value("page3_head$_"), "head$_"),
		    1..3,
		),
	    ])),
	    Acknowledgement(),
	    DIV_content([view_widget_value('page3_content')]),
	    DIV_foot(Join([
		map(
		    DIV(view_widget_value("page3_foot$_"), "foot$_"),
		    1..3,
		),
	    ])),
	]),
	style => view_widget_value('page3_style'),
	xhtml => 1,
    );
}

1;
