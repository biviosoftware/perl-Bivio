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
	[head1 => Link(Tag(span => ''), 'SITE_ROOT')],
	[head2 => Tag(div => Prose(view_widget_value('page3_title')), 'title')],
	['head3'],
	['content'],
	[foot1 => Link(String('back to top'), '#top')],
	['foot2'],
	[foot3 => P(Join([
	    'Copyright &copy; ',
	    Bivio::Type::DateTime->now_as_year,
	    ' ',
	    vs_text('site_copyright'),
	    '<br />All rights reserved.<br />',
	    Link('Developed by bivio', 'http://www.bivio.biz'),
	]))],
	[style => StyleSheet('/f/base.css')],
    ));
    return $proto->SUPER::new($attrs)->put_unless_exists(
	head => Join([
	    Title([vs_site_name(), Prose(view_widget_value('page3_title'))]),
	    view_widget_value('page3_meta_info'),
	]),
	body => Join([
	    '<a name="top"></a>',
	    Tag('div',
		Join([
		    map(
			Tag(div => view_widget_value("page3_head$_"), "head$_"),
			1..3,
		    ),
		]),
		'head',
	    ),
	    Acknowledgement(),
	    Tag(div => [view_widget_value('page3_content')], 'content'),
	    Tag(div =>
		Join([
		    map(
			Tag(div => view_widget_value("page3_foot$_"), "foot$_"),
			1..3,
		    ),
		]),
		'foot',
	    ),
	]),
	style => view_widget_value('page3_style'),
	xhtml => 1,
    );
}

1;
