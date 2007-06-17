# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::RealmFilePage;
use strict;
use Bivio::Base 'HTMLWidget.Page';
use Bivio::UI::HTML::Widget::ControlBase;
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ATTRS) = [qw(view_attr_prefix realm_id path default_path)];
my($_D) = Bivio::Type->get_instance('Date');

sub initialize {
    my($self) = shift;
    $self->map_invoke(initialize_attr => $_ATTRS);
    $self->internal_initialize_head_attrs(@_);
    return;
}

sub internal_new_args {
    shift;
    return Bivio::UI::HTML::Widget::ControlBase
	->internal_compute_new_args($_ATTRS, \@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    $self->internal_setup_xhtml($req);
    my($rid) = $self->render_simple_attr('realm_id', $source);
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    $rf->unauth_load({
	realm_id => $rid,
	path => $self->render_simple_attr('path', $source),
    }) or $rf->unauth_load_or_die({
	realm_id => $rid,
	path => $self->render_simple_attr('default_path', $source),
    });
    my($b) = $rf->get_content;
    my($vap) = $self->render_simple_attr('view_attr_prefix');
    $$b =~ s{
        \<\!--\s*bivio-([\w-]+)\s*--\>
	| \<\!--\s*start-bivio-([\w-]+)\s*--\>
	.*?\<\!--\s*end-bivio-([\w-]+)\s*--\>
    }{_render_view_attr($self, $source, $vap, [$1, $2, $3])}sigex;
    $$b =~ s{(?=\</head\>)}{@{[$self->internal_render_head_attrs($source)]}}is
	or $self->die($b, $source, 'missing </head>');
    $$buffer .= $$b;
    return;
}

sub _render_view_attr {
    my($self, $source, $vap, $matches) = @_;
    my($a) = $matches->[0];
    unless ($a) {
	$a = $matches->[1];
	Bivio::IO::Alert->warn(
	    $a, ' != ', $matches->[2], ': start/end-bivio do not agree',
	) unless $a eq $matches->[2];
    }
    $a =~ s/\W/_/g;
    $a = "$vap$a";
    return ${$self->render_value($a, view_get($a), $source)};
}

1;
