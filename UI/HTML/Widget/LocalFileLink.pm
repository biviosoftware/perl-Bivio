# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::LocalFileLink;
use strict;
use Bivio::Base 'UI.Widget';
b_use('UI.ViewLanguageAUTOLOAD');


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
    my($uri) = _get_uri_or_die($source, $fn);
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

sub _get_uri_or_die {
    my($source, $file_name) = @_;
    my($facade) = UI_Facade()->get_from_source($source);
    my($uri);
    foreach my $l (qw(app common)) {
	my($method) = "get_local_file_plain_${l}_uri";
	my($u) = $facade->$method(_path_by_location($l, $file_name));
	if (my $tagged_uri = Type_CacheTagFilePath()->from_local_path(
	    $facade->get_local_plain_file_name($u), $u)) {
	    $uri = $tagged_uri;
	    last;
	}
    }
    b_die($file_name, ': local file not found')
	unless $uri;
    return $uri;
}

sub _path_by_location {
    my($location, $file_name) = @_;
    return $location eq 'app'
	? Type_FilePath()->join(
	    Type_FilePath()->get_suffix($file_name), $file_name)
	: $file_name;
}

1;
