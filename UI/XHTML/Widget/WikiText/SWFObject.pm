# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::SWFObject;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub handle_register {
    return ['b-swfobject'];
}

# ffmpeg -i x.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus x.webm
sub render_html {
    sub RENDER_HTML {[
        'width',
        'file',
        [qw(id String b_video)],
        # UNUSED since going to <video>; Aspect ratio will be preserved without height
        '?height',
        '?data',
        '?noflash',
        '?preview',
    ]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
        unless $proto;
    # always include webm format. Necessary for any legit app
    (my $w = $attrs->{file}) =~ s{\.mp4$}{.webm};
    b_die($attrs->{file}, ': only mp4 supported')
        if $attrs->{file} eq $w;
    return <<"EOF";
<video controls preload="metadata" id="$attrs->{id}" width="$attrs->{width}">
<source src="$attrs->{file}" type="video/mp4">
<source src="$w" type="video/webm">
Your browser does not support video.
</video>
EOF

}

1;
