# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::AtomFeed;
use strict;
use Bivio::Base 'XMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('value');
    my($class) = Bivio::Biz::Model->get_instance($self->get('list_class'))
	->simple_package_name;
    $self->put(
	VERSION => '0.3',
	XMLNS => 'http://purl.org/atom/ns#',
	tag => 'feed',
	value => => Join([
	    map(
		Tag($_ => String(Prose(vs_text("rsspage.prose.$class.$_")))),
		qw(title tagline),
	    ),
	    EmptyTag(link => {
		HREF => URI({
		    require_absolute => 1,
		    task_id => [[qw(->req task html_task)], '->get_name'],
		    query => undef,
		}),
		REL => 'alternate',
		TYPE => 'text/html',
	    }),
	    If(["Model.$class", '->get_result_set_size'],
	       Tag(modified => DateTime(
		   [["Model.$class", '->set_cursor_or_die', 0],
			'->get_modified_date_time'],
	       )),
	    ),
	    WithModel($class => Tag(entry => Join([
		Tag(title => String(['title'])),
		Tag(summary => CDATA(['->get_rss_summary'])),
		Tag(modified => DateTime(['->get_modified_date_time'])),
		EmptyTag(link => {
		    HREF => URI({
			require_absolute => 1,
			task_id => [[qw(->req task html_task)], '->get_name'],
			path_info => ['path_info'],
			require_absolute => 1,
			query => ['query'],
		    }),
		    REL => 'alternate',
		    TYPE => 'text/html',
		}),
	    ]))),
	]),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $list_class, $attrs) = @_;
    return {
	list_class => $list_class,
	($attrs ? %$attrs : ()),
    };
}


1;
