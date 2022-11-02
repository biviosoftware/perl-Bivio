# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RealmCSS;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_REALM_PLACEHOLDER) = b_use('Type.RealmName')->SPECIAL_PLACEHOLDER;
my($_R) = b_use('Type.Regexp');
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_M) = b_use('Biz.Model');
my($_V) = b_use('UI.View');

sub NEW_ARGS {
    return [qw(?view_name)];
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($req) = $self->req;
    $$buffer .= _match_uri(
        _compress(
            join("\n",
                 ${$_V->render($self->render_simple_attr('view_name', $source), $req)},
                 @{$_M->new($req, 'RealmCSSList')->load_all
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
        [view_name => 'CSS->site_css'],
    ]);
    return shift->SUPER::initialize(@_);
}

sub _compress {
    my($v) = @_;
    $v =~ s/^\!.*\n//mg;
    $v =~ s/^\s+//mg;
    # IE BUG: Don't include ')', because "Icon('bla'); left" will get
    # convereted to "Icon('bla');left" which then becomes "url(/i/bla.gif)left"
    # which IE doesn't interpret properly and doesn't render the image
    $v =~ s/(?<!\))(?<=[\,\:\{])\s+//mg;
    return $v;
}

sub _match_uri {
    my($style, $req) = @_;
    my($uri) = _uri($req);
    $style =~ s{\^(\S+)}{
        my($text) = $1;
        my($comma) = $text =~ s/,$//s ? ',' : '';
        my($re, $err) = $_R->from_literal($text);
        unless ($re) {
            Bivio::IO::Alert->warn($re, ': ', $err || $_NULL, '; ', $req);
            $re = 'IGNORE-INVALID-REGEXP';
        }
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
