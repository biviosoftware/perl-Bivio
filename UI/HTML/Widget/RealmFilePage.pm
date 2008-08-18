# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::RealmFilePage;
use strict;
use Bivio::Base 'HTMLWidget.Page';
use Bivio::UI::HTML::Widget::ControlBase;
use Bivio::UI::ViewLanguageAUTOLOAD;
use URI ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ATTRS) = [qw(view_attr_prefix realm_id path default_path)];
my($_FP) = Bivio::Type->get_instance('FilePath');

sub execute {
    my($self, $req) = @_;
    $self->execute_with_content_type($req, 'text/html');
    $req->get('reply')->set_output_type($req->get("$self"));
    return;
}

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
    my($p) = $self->render_simple_attr('path', $source);
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    $p && $rf->unauth_load({
	realm_id => $rid,
	path => $p,
    }) or $rf->unauth_load_or_die({
	realm_id => $rid,
	path => $self->render_simple_attr('default_path', $source),
    });
    $req->put("$self" => $rf->get_content_type);
    my($b) = $rf->get_content;
    $p = $rf->get('path');
#TODO: Encapsulate
    $p = $_FP->from_public($p)
	if $rf->get('is_public');
    $p = URI->new($rf->get_request->format_http({uri => $p}));
    $$b =~ s{(\b(?:href|src)=")([^"]+)}{$1 . _render_uri($2, $p)}sige;
    my($vap) = $self->render_simple_attr('view_attr_prefix', $source);
    $$b =~ s{
        \<\!--\s*bivio-([\w-]+)\s*--\>
	| \<\!--\s*start-bivio-([\w-]+)\s*--\>
	.*?\<\!--\s*end-bivio-([\w-]+)\s*--\>
    }{_render_view_attr($self, $source, $vap, [$1, $2, $3])}sigex;
    # It's ok to be missing a <head> so we can use for XML
    if (my $h = $self->internal_render_head_attrs($source)) {
	$$b =~ s{(?<=\<head\>)}{\n$h}is
	    or $self->die($b, $source, 'missing <head>');
    }
    $$buffer .= $$b;
    return;
}

sub _render_uri {
    my($rel, $file_uri) = @_;
    # URI doesn't support cid:
    return $rel
	if $rel =~ /^cid:/;
    my($abs) = URI->new($rel);
    return $rel
	if $abs->scheme || $abs->path =~ m{^(/|$)};
    $abs = $abs->abs($file_uri);
    my($q) = $abs->query;
    my($f) = $abs->fragment;
    return $abs->path . (defined($q) ? "?$q" : '') . (defined($f) ? "#$f" : '');
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
    my($die);
    my($res) = Bivio::Die->catch(
	sub {$self->render_value($a, view_get($a), $source)},
	\$die,
    );
    return $res ? $$res
	: ('TAG-ERR' . ($source->req->is_test ? ': ' . $die->as_string : ''));
}

1;
