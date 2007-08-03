# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::MIMEEntityRealmFile;
use strict;
use Bivio::Base 'Widget.ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($rf) = $self->resolve_attr('realm_file', $source);
    my($t) = $rf->get_content_type;
    my($c) = $rf->get_content;
    $self->get_request->put(
	"$self" => MIME::Entity->build(
	    Type => $t,
	    Filename => $_FP->get_tail($rf->get('path')),
	    Data => $c,
	    Encoding => Bivio::MIME::Type->suggest_encoding($t, $c),
	    Disposition => $self->render_simple_attr('mime_disposition'),
	),
    );
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('realm_file');
    $self->initialize_attr(mime_disposition => 'attachment');
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $realm_file, $attributes) = @_;
    return '"realm_file" attribute must be defined'
	unless defined($realm_file);
    return {
	realm_file => $realm_file,
	($attributes ? %$attributes : ()),
    };
}

sub mime_entity {
    my($self, $source) = @_;
    return $source->get_request->unsafe_get("$self");
}

1;
