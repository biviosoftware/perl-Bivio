# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MainErrors::WikiValidator;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WV) = b_use('Action.WikiValidator');
b_use('XHTMLWidget.MainErrors')->register_handler(__PACKAGE__);

sub error_list_widget {
    return WithModel(WikiErrorList => Join([
	Join([
	    String(['path']),
	    Join([
		', line ',
		String(['line_num']),
	    ], {control => ['line_num']}),
	    ': ',
	], {control => ['path']}),
	Join([
	    String(['entity']),
	    ': ',
	], {control => ['entity']}),
	String(['message']),
	LineBreak(),
    ]));
}

sub handle_render_main_errors {
    my($self) = shift;
    my($source) = @_;
    return
	unless my $wv = $_WV->unsafe_self_from_req($source->req);
    Join([
	DIV_b_title(vs_text('WikiValidator.title')),
	$self->error_list_widget,
    ])->initialize_and_render(@_)
	if $wv->unsafe_load_error_list;
    return;
}

sub initialize {
    return shift->SUPER::initialize(@_);
}

1;
