# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiStyle;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = __PACKAGE__->use('Type.WikiName');
my($_WT) = __PACKAGE__->use('XHTMLWidget.WikiText');
my($_RF) = __PACKAGE__->use('Action.RealmFile');

sub help_exists {
    my($proto, $name, $req) = @_;
    return $_RF->access_controlled_load(
	vs_constant($req, 'help_wiki_realm_id'),
	$_WN->to_absolute($name),
	$req,
	1,
    ) ? 1 : 0;
}

sub prepare_html {
    shift;
#TODO: Deprecate
    return $_WT->prepare_html(@_);
}

sub render {
    # History: Used to render a style, now handled by RealmCSSList
    return;
}

sub render_help_html {
    my($self, $name, $req) = @_;
    return ($self->render_html(
	vs_constant($req, 'help_wiki_realm_id'),
	$name,
	Bivio::Agent::TaskId->HELP,
	$req,
	vs_constant($req, 'help_wiki_realm_name'),
    ))[0];
}

sub render_html {
    return map(
	ref($_) eq 'HASH' ? \($_WT->render_html($_)) : $_,
	shift->prepare_html(@_),
    );
}

1;
