# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::MIMEEntityView;
use strict;
use Bivio::Base 'Widget.ControlBase';

my($_V) = b_use('UI.View');

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    $$buffer .= ${$_V->render(
        $self->render_simple_attr(view_name => $source),
        $req,
    )};
    $req->put("$self" => $req->get('reply')->get_output_type);
    return;
}

sub control_off_render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    # So mime_type render doesn't blow up when control is false
    $req->put("$self" => '');
    return;
}

sub initialize {
    my($self) = @_;
    $self->map_invoke(initialize_attr => [
        ['view_name'],
        [mime_type => ['->req', "$self"]],
        [mime_charset => 'us-ascii'],
        [mime_encoding => [sub {
            shift->req("$self") =~ m{^text/}i ? 'quoted-printable' : 'base64';
        }]],
    ]);
    return;
}

sub internal_new_args {
    my(undef, $view_name, $attributes) = @_;
    return '"view_name" attribute must be defined'
        unless defined($view_name);
    return {
        view_name => $view_name,
        ($attributes ? %$attributes : ()),
    };
}

1;
