# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::View::Base;
use strict;
use base 'Bivio::UI::View::Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VIEW_SHORTCUTS {
    return 'Bivio::UI::XHTML::ViewShortcuts';
}

sub csv {
    my($self) = @_;
    view_class_map('TextWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    return;
}

sub internal_base_type {
    my($self) = @_;
    return ''
	unless my $p = $self->unsafe_get('parent');
    while (my $pp = $p->unsafe_get('parent')) {
	$p = $pp;
    }
    return $p->get('view_name');
}

sub mail {
    my($self) = @_;
    view_class_map('MailWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_declare(qw(mail_body mail_to mail_subject));
    view_put(
	mail_from => Mailbox(
	    vs_text('support_email'),
	    $self->internal_text_as_prose('support_name'),
	),
	mail_recipients => '',
    );
    view_main(Message({
	from => view_widget_value('mail_from'),
	to => view_widget_value('mail_to'),
	subject => view_widget_value('mail_subject'),
	body => view_widget_value('mail_body'),
	recipients => view_widget_value('mail_recipients'),
    }));
    return;
}

sub internal_body {
    return shift->internal_put_base_attr(body => @_);
}

sub internal_body_from_name_as_prose {
    my($self, $name) = @_;
    return $self->internal_body(
	$self->internal_text_as_prose($name || $self->get('view_name')));
}

sub internal_put_base_attr {
    my($self) = shift;
    $self->map_by_two(sub {
        view_put($self->internal_base_type . '_' . shift(@_) => shift(@_));
	return;
    }, \@_);
    return;
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
	xhtml_pager => '',
	xhtml_menu => TaskMenu([
	    'USER_PASSWORD',
	]),
    );
    return Page3({
	head1 => $self->internal_text_as_prose('page3.head1'),
	head2 => Join([
	    P_realm(view_widget_value('xhtml_realm')),
	    P_menu(view_widget_value('xhtml_menu')),
	    P_title($self->internal_text_as_prose('xhtml_title')),
	]),
	head3 => Director(['user_state', '->get_name'], {
	    JUST_VISITOR => XLink('USER_CREATE'),
	    LOGGED_OUT => XLink('my_site_login'),
	    LOGGED_IN => XLink('LOGOUT'),
	}),
	content => Join([
	    DIV_top(Join([
		DIV_tools(Join([
		    view_widget_value('xhtml_tools'),
		    view_widget_value('xhtml_pager'),
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
		    view_widget_value('xhtml_pager'),
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

sub pre_compile {
    my($self) = @_;
    my($n) = $self->get('view_name');
    return
	if __PACKAGE__->can($n);
    view_parent('Base->' . ($n =~ /_(mail|csv|rss)$/ ? $1 : 'xhtml'));
#    view_parent(($n =~ /_(mail|csv|rss)$/ ? $1 : 'xhtml'));
    return;
}

sub rss {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    return;
}

sub xhtml {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_put(
	xhtml_body => '',
    );
    view_main(Director([
	sub {shift->get_request->isa('Bivio::Agent::Embed::Request') ? 1 : 0},
    ], {
	1 => SimplePage(view_widget_value('xhtml_body')),
	0 => $self->internal_xhtml_adorned,
    }));
    return;
}


1;
