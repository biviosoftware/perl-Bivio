# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MainErrors::WikiValidator;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WV) = b_use('Action.WikiValidator');
b_use('XHTMLWidget.MainErrors')->register_handler(__PACKAGE__);

sub handle_render_main_errors {
    my($self) = shift;
    my($source) = @_;
    return
	unless my $wv = $_WV->unsafe_self_from_req($source->req);
    my($entity) = '';
    Join([map(_item($_, \$entity, $source), @{$wv->get('errors')})])
	->initialize_and_render(@_),
    return;
}

sub initialize {
    return shift->SUPER::initialize(@_);
}

sub _item {
    my($error, $entity, $source) = @_;
    return (
	length($$entity) ? () : DIV_b_title(vs_text('wiki_validator_title')),
	$$entity eq $error->{entity} ? ()
	    : DIV_b_entity(String(($$entity = $error->{entity}) . ':')),
	DIV_b_item(String(
	    Join([
		$error->{line_num} ? "line $error->{line_num}: " : (),
		$error->{message},
		!$error->{entity_in_error} ? ()
		    : qq{; text is "$error->{entity_in_error}"},
	    ]),
	    {escape_html => 1, hard_newlines => 1},
	)),
    );
}

1;
