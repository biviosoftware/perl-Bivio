# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Base;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_WANT_USER_AUTH)
    = b_use('Agent.TaskId')->is_component_included('user_auth');

sub PARENT_CLASS {
    # Do not override this unless you know what you are doing.
    return __PACKAGE__->simple_package_name;
}

sub VIEW_SHORTCUTS {
    return 'UIXHTML.ViewShortcuts';
}

sub css {
    my($self) = @_;
    view_class_map('CSSWidget');
    view_shortcuts('UICSS.ViewShortcuts');
    view_declare('css_body');
    view_main(SimplePage({
	content_type => 'text/css',
	value => view_widget_value('css_body'),
    }));
    return;
}

sub csv {
    my($self) = @_;
    view_class_map('TextWidget');
    view_declare('csv_body');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_main(SimplePage({
	content_type => 'text/csv',
	value => view_widget_value('csv_body'),
    }));
    return;
}

sub imail {
    my($self) = @_;
    view_main(SimplePage({
	content_type => 'message/rfc822',
	value => _mail($self),
    }));
    return;
}

sub internal_base_attr {
    return shift->internal_base_type . '_' . shift;
}

sub internal_base_type {
    my($self) = @_;
    return $self->get('view_name')
	unless my $p = $self->unsafe_get('parent');
    while (my $pp = $p->unsafe_get('parent')) {
	$p = $pp;
    }
    return $p->get('view_name');
}

sub internal_body {
    return shift->internal_put_base_attr(body => @_);
}

sub internal_body_prose {
    return shift->internal_body(Prose(@_));
}

sub internal_put_base_attr {
    my($self) = shift;
    view_put(
	@{$self->map_by_two(
	    sub {($self->internal_base_attr(shift) => shift)},
	    \@_,
	)},
    );
    return $self;
}

sub internal_text_as_prose {
    my($self, $name) = @_;
    return vs_text_as_prose($self->simple_package_name . '.' . $name);
}

sub internal_xhtml_adorned {
    my($self) = @_;
    view_put(
	xhtml_realm => '',
	xhtml_tools => '',
	xhtml_topic => '',
	xhtml_byline => '',
	vs_pager => '',
	xhtml_want_first_focus => 1,
	xhtml_body_first => Join([
	    EmptyTag(a => {html_attrs => ['name'], name => 'top'}),
            vs_first_focus(view_widget_value('xhtml_want_first_focus')),
	]),
    );
    return Page3({
	body_first => view_widget_value('xhtml_body_first'),
	head2 => Join([
	    P_realm(view_widget_value('xhtml_realm')),
	    P_title(vs_text_as_prose('xhtml_title')),
	]),
	head3 => $_WANT_USER_AUTH ? Director(['user_state', '->get_name'], {
	    JUST_VISITOR => XLink('USER_CREATE'),
	    LOGGED_OUT => XLink('my_site_login'),
	    LOGGED_IN => XLink('LOGOUT'),
	}) : '',
	content => Join([
	    view_widget_value('xhtml_body_first'),
	    DIV_top(Join([
		DIV_tools(Join([
		    view_widget_value('xhtml_tools'),
		    view_widget_value('vs_pager'),
		], {
		    join_separator => EmptyTag(DIV => 'sep'),
		})),
		map(
		    DIV(view_widget_value("xhtml_$_"), $_),
		    qw(topic byline),
		),
	    ])),
	    DIV_body(view_widget_value('xhtml_body')),
	    DIV_bottom(
		DIV_tools(Join([
		    view_widget_value('xhtml_tools'),
		    view_widget_value('vs_pager'),
		], {
		    join_separator => EmptyTag(DIV => 'sep'),
		})),
	    ),
	]),
	foot2 => TaskMenu([
	    'SITE_ROOT',
	]),
    });
}

sub js {
    my($self) = @_;
    view_class_map('JavaScriptWidget');
    view_declare('js_body');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_main(SimplePage({
	content_type => 'text/javascript',
	value => view_widget_value('js_body'),
    }));
    return;
}

sub json {
    my($self) = @_;
#TODO: Errors are caught and render as simple strings, no body; with tracing in log
    view_class_map('XHTMLWidget');
    view_declare('json_body');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_main(SimplePage({
	content_type => 'application/json',
	value => view_widget_value('json_body'),
    }));
    return;
}

sub mail {
    my($self) = @_;
    view_main(_mail($self));
    return;
}

sub pre_compile {
    my($self) = @_;
    my($n) = $self->get('view_name');
    view_parent(
	$self->PARENT_CLASS
	. '->'
	. ($n =~ /_(imail|js|mail|csv|rss|css|xml|xhtml_widget|json)$/ ? $1 : 'xhtml')
    ) unless $self->use('View.' . $self->PARENT_CLASS)->can($n);
    return;
}

sub rss {
    my($self) = @_;
    view_class_map('XMLWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_declare('rss_body');
    view_main(SimplePage(view_widget_value('rss_body'), {
	content_type => 'application/atom+xml',
    }));
    return;
}

sub xml {
    my($self) = @_;
#TODO: Real XML support
    view_class_map('XMLWidget');
    view_declare('xml_body');
    view_put(xml_content_encoding => '');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_main(Page({
	value => view_widget_value('xml_body'),
	content_encoding => view_widget_value('xml_content_encoding'),
    }));
    return;
}

sub xhtml {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_put(
	xhtml_body => '',
    );
    # Use Director because it is executable ("If" isn't)
    view_main(Director(
	[sub {shift->req->isa('Bivio::Agent::Embed::Request') ? 1 : 0}],
	{
	    1 => SimplePage(view_widget_value('xhtml_body')),
	    0 => $self->internal_xhtml_adorned,
	}));
    return;
}

sub xhtml_widget {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_declare('xhtml_widget_body');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_main(SimplePage({
	content_type => 'text/xhtml+xml',
	value => view_widget_value('xhtml_widget_body'),
    }));
    return;
}

sub _mail {
    my($self) = @_;
    view_class_map('MailWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    my($a) = [qw(body to cc bcc headers_object subject)];
    $self->internal_put_base_attr(
	map(($_ => ''), @$a),
	from => Mailbox(
	    vs_text('support_email'),
	    vs_text_as_prose('support_name'),
	),
	recipients => '',
	control => 1,
    );
    return Message({
	map(
	    ($_ => view_widget_value($self->internal_base_attr($_))),
	    @$a,
	    qw(
	        from
		recipients
		control
	    ),
	),
    });
}

1;
