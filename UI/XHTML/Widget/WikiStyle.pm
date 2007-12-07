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
    my($proto, $realm_id, $name, $task_id, $req, $realm_name) = @_;
    return unless my $rf = $_RF->access_controlled_load(
	$realm_id, $_WN->to_absolute($name), $req, 1);
    my($v) = ${$rf->get_content};
    my($t);
    my($wiki_args) = {
	task_id => $task_id,
	req => $req,
	name => $name,
	map(($_ => $rf->get($_)), qw(is_public realm_id)),
    };
    if ($v =~ s{^(\@h1[ \t]*\S[^\r\n]+\r?\n|\@h1.*?\r?\n\@/h1\s*?\r?\n)}{}s) {
	my($x) = $1;
	$t = ($_WT->render_html({
	    %$wiki_args,
	    value => $x,
	}) =~ m{^<h1>(.*)</h1>$}s)[0];
	if (defined($t)) {
	    $t =~ s/^\s+|\s+$//g;
	}
	else {
	    Bivio::IO::Alert->warn(
		$x, ': not a header pattern; page=', $name);
	    substr($v, 0, 0) = $x;
	}
    }
    return (
	{
	    %$wiki_args,
	    value => $v,
	    title => defined($t) ? $t
		: Bivio::HTML->escape($_WN->to_title($name)),
	},
	$rf->get(qw(modified_date_time user_id)),
    );
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
