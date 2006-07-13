# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiStyle;
use strict;
use base 'Bivio::UI::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName');
my($_WT) = Bivio::Type->get_instance('WikiText');

sub render {
    my($self, $source, $buffer) = @_;
    my($styles) = $source->get_request->unsafe_get(__PACKAGE__);
    return unless $styles && @$styles;
    $$buffer .= join(
	"\n",
	qq{<style type="text/css">\n<!--},
	@$styles,
	"-->\n</style>\n"
    );
    return;
}

sub render_html {
    my($proto, $name, $req, $task_id, $realm_id) = @_;
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    return unless $rf->unauth_load({
	path => $_WN->to_absolute($name),
	realm_id => $realm_id,
    });
    my($res) = [
	\($_WT->render_html($rf->get_content, $name, $req, $task_id)),
	$rf->get(qw(modified_date_time user_id)),
    ];
    if ($rf->unauth_load({
	path => $_WN->to_absolute('base.css'),
	realm_id => $realm_id,
    })) {
	my($styles) = $req->get_if_exists_else_put(__PACKAGE__, []);
	my($s) = $rf->get_content;
	# Avoid duplicates (HelpWiki and WikiView on same page)
	push(@$styles, $$s)
	    unless grep($$s eq $_, @$styles);
    }
    return @$res;
}

1;
