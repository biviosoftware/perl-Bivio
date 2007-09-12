# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
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
    my($public) = $req->unsafe_get('Type.AccessMode');
    $public = $public ? $public->eq_public : 0;
    foreach my $mode ($public .. 1) {
	$public = $mode;
	last if $rf->unauth_load({
	    path => $_WN->to_absolute($name, $mode),
	    realm_id => $realm_id,
	    is_public => $mode,
	});
    }
    return
	unless $rf->is_loaded;
    my($res) = [
	\($_WT->render_html($rf->get_content, $name, $req, $task_id)),
	$rf->get(qw(modified_date_time user_id)),
    ];
    if ($rf->unauth_load({
	path => $_WN->to_absolute('base.css', $public),
	realm_id => $realm_id,
	is_public => $public,
    })) {
	my($styles) = $req->get_if_exists_else_put(__PACKAGE__, []);
	my($s) = $rf->get_content;
	# Avoid duplicates (HelpWiki and WikiView on same page)
	push(@$styles, _class($name, $$s))
	    unless grep($$s eq $_, @$styles);
    }
    return @$res;
}

sub _class {
    my($name, $style) = @_;
    my($f) = __PACKAGE__->use('HTMLFormat.WikiNameToClass');
    $style =~ s{\^(\S+)}{
        my($re) = $1;
	my($comma) = $re =~ s/,$//s ? ',' : '';
	'.'
	. ($name =~ qr{^$re$} ? $f->get_widget_value($name) : 'NOT-THIS-WIKI')
	. $comma;
    }exig;
    return $style;
}

1;
