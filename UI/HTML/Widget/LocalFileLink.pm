# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::LocalFileLink;
use strict;
use Bivio::Base 'UI.Widget';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(file_name)];
}

sub initialize {
    my($self, $source) = @_;
    $self->initialize_attr($self->NEW_ARGS->[0], undef, $source);
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($fn) = $self->render_simple_attr('file_name', $source);
    my($type) = $self->to_html_type_attr($fn);
#TODO: Look in app and then common.  If not found, throw err
    my($uri) = UI_Facade()->get_from_source($source)
	->get_local_file_plain_app_uri(
	    Type_FilePath()->join(
		Type_FilePath()->get_suffix($fn),
		$fn,
	    ),
	);
    HTMLWidget_Tag({
	tag => $type =~ /javascript/ ? (
	    'script',
	    SRC => $uri,
	    value => '',
	) : (
	    'link',
	    HREF => $uri,
	    REL => 'stylesheet',
	),
	TYPE => $type,
    })->initialize_and_render($source, $buffer);
    return;
}

sub to_html_type_attr {
    my(undef, $file) = @_;
    return Type_FilePath()->get_suffix($file) =~ /(js|css)/
	? $1 eq 'js'
	? 'text/javascript'
	: 'text/css'
	: b_die($file, ': unrecognized file suffix');
}

1;
