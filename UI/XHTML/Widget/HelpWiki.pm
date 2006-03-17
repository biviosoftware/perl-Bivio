# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::HelpWiki;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::XHTML::Widget::WikiStyle;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_WT) = Bivio::Type->get_instance('WikiText');
my($_WN) = Bivio::Type->get_instance('WikiName');

sub AUTOLOAD {
    return Bivio::UI::ViewLanguage->call_method(
	$AUTOLOAD, 'Bivio::UI::ViewLanguage', @_,
    );
}

sub new {
    my($self) = shift->SUPER::new(@_);
    return $self->put_unless_exists(
	tag => 'div',
	id => 'help_wiki',

	# You do not want to override these values
	control => [
	    sub {
		my($req) = shift->get_request;
		my($t) = Bivio::UI::Text->get_from_source($req);
		my($name) = $t->get_value(
		    'title', $req->get('task_id')->get_name);
		$name =~ s/\W//g;
		return 0
		    unless my($html) = Bivio::UI::XHTML::Widget::WikiStyle
			->render_html(
			    $name . 'Help',
			    $req,
			    Bivio::Agent::TaskId->HELP,
			    $t->get_value('help_wiki_realm_id'));
		$req->put("$self" => $$html);
		return 1;
	    },
	],
        value => RoundedBox([
	    Tag(div => Prose(vs_text('helpwiki.header')), 'header'),
	    Tag(div => ["$self"], 'body'),
	    Tag(div => Prose(vs_text('helpwiki.footer')), 'footer'),
	]),
    );
}

1;
