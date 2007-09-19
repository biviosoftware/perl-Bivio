# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiStyle;
use strict;
use base 'Bivio::UI::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = __PACKAGE__->use('Type.WikiName');
my($_WT) = __PACKAGE__->use('XHTMLWidget.WikiText');

sub help_exists {
    my($proto, $name, $req) = @_;
    return $proto->use('Action.RealmFile')->access_controlled_load(
	Bivio::UI::Constant->get_from_source($req)
	    ->get_value('help_wiki_realm_id'),
	$_WN->to_absolute($name),
	$req,
    ) ? 1 : 0;
}

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

sub render_help_html {
    my($self, $name, $req) = @_;
    return ($self->render_html(
	Bivio::UI::Constant->get_from_source($req)
	    ->get_value('help_wiki_realm_id'),
	$name,
	Bivio::Agent::TaskId->HELP,
	$req,
    ))[0];
}

sub render_html {
    my($proto, $realm_id, $name, $task_id, $req) = @_;
    return unless my $rf = $proto->use('Action.RealmFile')
	->access_controlled_load($realm_id, $_WN->to_absolute($name), $req);
    my($res) = [
	\($_WT->render_html({
	    value => ${$rf->get_content},
	    task_id => $task_id,
	    req => $req,
	    name => $name,
	    map(($_ => $rf->get($_)), qw(is_public realm_id)),
	})),
	$rf->get(qw(modified_date_time user_id)),
    ];
    if ($rf->unauth_load({
	path => $_WN->to_absolute('base.css', $rf->get('is_public')),
	realm_id => $realm_id,
	is_public => $rf->get('is_public'),
    })) {
	my($styles) = $req->get_if_exists_else_put(__PACKAGE__, []);
	my($s) = _class($name, ${$rf->get_content});
	# Avoid duplicates (HelpWiki and WikiView on same page)
	push(@$styles, $s)
	    unless grep($s eq $_, @$styles);
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
