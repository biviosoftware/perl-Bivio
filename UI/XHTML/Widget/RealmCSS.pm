# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RealmCSS;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_REALM_PLACEHOLDER)
    = __PACKAGE__->use('Type.RealmName')->SPECIAL_PLACEHOLDER;

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($req) = $self->req;
    $$buffer .= _match_uri(
	_compress(
	    join("\n",
		 ${Bivio::UI::View->render('CSS->site_css', $req)},
		 @{Bivio::Biz::Model->new($req, 'RealmCSSList')->load_all
	            ->map_rows(sub {${shift->get_content}})},
	     ),
	),
	$req,
    );
    return;
}

sub initialize {
    my($self) = @_;
    $self->map_invoke(initialize_attr => [
	[value => ''],
	[bracket_value_in_comment => 1],
	[tag => 'style'],
	[TYPE => 'text/css'],
	[tag_if_empty => 0],
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([], \@_);
}

sub _compress {
    my($v) = @_;
    $v =~ s/^\!.*\n//mg;
    $v =~ s/^\s+//mg;
    # IE BUG: Don't include ';', because "Icon('bla'); left" will get
    # convereted to "Icon('bla');left" which then becomes "url(/i/bla.gif)left"
    # which IE doesn't interpret properly and doesn't render the image
    $v =~ s/(?<!\))(?<=[\,\:\{])\s+//mg;
    return $v;
}

sub _match_uri {
    my($style, $req) = @_;
    my($uri) = _uri($req);
    $style =~ s{\^(\S+)}{
        my($re) = $1;
	if ($re =~ m{\(\?}) {
	    Bivio::IO::Alert->warn($re, ': class regex too complex: ', $req);
	    $re = 'IGNORE-INVALID-REGEXP';
        }
	my($comma) = $re =~ s/,$//s ? ',' : '';
	($uri =~ m{^$re$}is ? 'body' : '.NO-MATCH') . $comma;
    }exig;
    return $style;
}

sub _uri {
    my($req) = @_;
    my($t) = $req->get('task_id');
    my($u) = vs_task_has_uri($req, $t) ? $req->format_uri({
	realm => $_REALM_PLACEHOLDER,
	task_id => $t,
	path_info => $req->get_or_default('path_info', ''),
	query => undef,
    }) : $req->get_or_default('uri', '/');
    return $u;
}

1;
