# Copyright (c) 2018 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::OpenGraphHead;
use strict;
use Bivio::Base 'XHTMLWidget.ControlBase';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision: 0.0$ =~ /\d+/g);
my($_REQ_KEY) = b_use('XHTMLWidget.OpenGraphProperty')->REQ_KEY;
my($_HS) = b_use('HTML.Scraper');
my($_S) = b_use('Type.String');

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($p) = $source->ureq($_REQ_KEY) || {};
    Join([
        META({
            PROPERTY => 'og:type',
            CONTENT => 'website',
        }),
        META({
            PROPERTY => 'og:site_name',
            CONTENT => vs_text('site_name'),
        }),
        META({
            PROPERTY => 'og:url',
            CONTENT => vs_canonical_uri_for_this_page(),
        }),
        map(
            META({
                PROPERTY => "og:$_",
                # Sometimes HTML, but we're excerpting.
                CONTENT => ${_excerpt($p->{$_})},
            }),
            sort(keys(%$p)),
        ),
    ])->initialize_and_render($source, $buffer);
    return;
}

sub initialize {
    my($self) = @_;
    $self->put(
        # only matters for anonymous users (robots)
        control => And(
            ['!', '->ureq', 'auth_user'],
            vs_task_has_uri(['->req', 'task_id']),
        ),
    );
    return shift->SUPER::initialize(@_);
}

sub _excerpt {
    my($v) = @_;
    # partial html needs to be encapsulated
    $v = "<html><body>$v</body></html>"
        unless $v =~ /<\s*html/i;
    return $_S->canonicalize_and_excerpt($_HS->to_text(\$v));
}

1;
