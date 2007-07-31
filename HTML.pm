# Copyright (c) 2000-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::HTML;
use strict;
use base 'Bivio::UNIVERSAL';
use HTML::Entities ();
use URI::Escape ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub escape {
    my(undef, $value) = @_;
    $value = HTML::Entities::encode($value);
    return $value;
}

sub escape_attr_value {
    my($proto, $text) = @_;
    # B<Netscape and IE seems to require that we escape the html inside the quotes
    # even though this isn't the standard.>
    return $proto->escape($text);
}

sub escape_query {
    my($proto, $text) = @_;
    # Same as escape_uri except escapes '+' and '?' as well.
    $text = $proto->escape_uri($text);
    $text =~ s/\+/\%2B/g;
    $text =~ s/\?/\%3F/g;  #don't let this fall through the cracks
    return $text;
}

sub escape_uri {
    my(undef, $value) = @_;
    $value = _extra_escape_uri(URI::Escape::uri_escape($value));
    return $value;
}

sub unescape_uri {
    my(undef, $value) = @_;
    $value = URI::Escape::uri_unescape($value);
    return $value;
}

sub unescape {
    my(undef, $text) = @_;
    $text =~ s/&amp;/&/g;
    $text =~ s/&quot;/"/g;
    $text =~ s/&lt;/</g;
    $text =~ s/&gt;/>/g;
    return $text;
}

sub unescape_query {
    my($proto, $value) = @_;
    $value =~ s/\+/ /g;
    return $proto->unescape_uri($value);
}

sub _extra_escape_uri {
    my($v) = @_;
    # Escapes & and = in URIs, because browsers don't do the right thing
    # in quoted strings.  Unescape '/'s because they shouldn't be escaped.
    $v =~ s/\=/%3D/g;
    $v =~ s/\&/%26/g;
    $v =~ s/%2F/\//g;
    return $v;
}

1;
