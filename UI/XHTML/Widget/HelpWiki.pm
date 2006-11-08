# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::HelpWiki;
use strict;
use base 'Bivio::UI::XHTML::Widget::RoundedBox';
use Bivio::UI::ViewLanguageAUTOLOAD;
use Bivio::UI::XHTML::Widget::WikiStyle;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WT) = Bivio::Type->get_instance('WikiText');
my($_WN) = Bivio::Type->get_instance('WikiName');

sub new {
    return shift->SUPER::new(@_ > 0 ? @_ : '');
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	class => 'help_wiki',
	tag => 'div',
    )->put(
	control => [
	    sub {
		my($req) = shift->get_request;
		my($name) = Bivio::UI::Text->get_from_source($req)->get_value(
		    'title', $req->get('task_id')->get_name);
		$name =~ s/\W//g;
		return 0
		    unless my($html) = Bivio::UI::XHTML::Widget::WikiStyle
			->render_html(
			    $name . 'Help',
			    $req,
			    Bivio::Agent::TaskId->HELP,
			    Bivio::UI::Constant->get_from_source($req)
				->get_value('help_wiki_realm_id'));
		$req->put("$self" => $$html);
		return 1;
	    },
	],
        value => Join([
	    Tag(div => Prose(vs_text('helpwiki.header')), 'header'),
	    Tag(div => [['->get_request'], "$self"], 'body'),
	    Tag(div => Prose(vs_text('helpwiki.footer')), 'footer'),
	]),
    );
    return shift->SUPER::initialize(@_);
}

1;
