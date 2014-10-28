# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::AtomFeed;
use strict;
use Bivio::Base 'XMLWidget.XMLDocument';
use Bivio::UI::ViewLanguageAUTOLOAD;

# Atom Format, RFC 4287
# validator at http://validator.w3.org/feed/


sub NEW_ARGS {
    return ['list_class'];
}

sub initialize {
    my($self) = @_;
    my($class) = b_use('Model.' . $self->get('list_class'))
	->simple_package_name;
    $self->put_unless_exists(
        value => Tag({
	    XMLNS => 'http://www.w3.org/2005/Atom',
	    tag => 'feed',
	    value => => Join([
		_id('html_task'),
		If(["Model.$class", '->get_result_set_size'],
		   Tag(updated => DateTime(
		       [["Model.$class", '->set_cursor_or_die', 0],
			    '->get_modified_date_time'],
		   )),
		),
		Tag(title => vs_text_as_prose('AtomFeed.title')),
		_link(alternate => 'html_task'),
		_link('self'),
		WithModel($class => Tag(entry => Join([
		    _id('html_detail_task'),
		    Tag(published => DateTime(['->get_creation_date_time'])),
		    Tag(updated => DateTime(['->get_modified_date_time'])),
		    Tag(title => vs_text_as_prose($class, 'AtomFeed.entry_title')),
		    Tag(content => vs_text_as_prose($class, 'AtomFeed.entry_content'),
			{TYPE => 'html'},
		    ),
		    _link(alternate => 'html_detail_task'),
		    Tag(author => Tag(name => String(['->get_rss_author']))),
		]))),
	    ]),
        }),
    );
    return shift->SUPER::initialize(@_);
}

sub _id {
    my($task_attr) = @_;
    # see http://validator.w3.org/feed/docs/error/InvalidTAG.html for format
    # avoid duplicates http://validator.w3.org/feed/docs/error/DuplicateIds.html
    return Tag(id => Join([
	'tag:',
#TODO: This should be encapsulated using URI() and req->http_prefix
	[sub {
	    my(undef, $host) = @_;
	    # strip port number
	    $host =~ s/\:\d+$//;
	    return $host;
	}, ['->req', qw(Bivio::UI::Facade http_host)]],
	',1999:',
	_uri($task_attr, {}),
    ]));
}

sub _link {
    my($type, $task_attr) = @_;
    return EmptyTag(link => {
	HREF => _uri($task_attr, {
	    require_absolute => 1,
	}),
	REL => $type,
	TYPE => $task_attr && $task_attr =~ /html/
	    ? 'text/html'
	    : 'application/atom+xml',
    });
}

sub _uri {
    my($task_attr, $attrs) = @_;
    return URI({
	task_id => [$task_attr
	    ? [[qw(->req task)], '->get_attr_as_id', $task_attr]
	    : [qw(->req task_id)],
	    '->get_name'],
	$task_attr && $task_attr =~ /detail/
	    ? (
		path_info => ['path_info'],
		query => ['query'],
		realm => [sub {
			     my($src) = shift;
			     return $src->unsafe_get('realm')
				 || $src->req(qw(auth_realm owner name));
			  }],
	    ) : (),
	%$attrs,
    });
}

1;
