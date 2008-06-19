# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::HTML;
use strict;
use base 'Bivio::UNIVERSAL';
use HTML::Entities ();
use URI::Escape ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub escape {
    my(undef, $text) = @_;
    return scalar(HTML::Entities::encode($text));
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
    return _extra_escape_uri(URI::Escape::uri_escape($value));
}

sub escape_xml {
    return shift->escape(@_);
}

sub parse_www_form_urlencoded {
    my($proto, $value) = @_;
    return {map({
	my(@x);
	if (defined($_) && length($_)) {
	    @x = map($proto->unescape_query($_), split(/=/, $_));
	    Bivio::Die->throw(CORRUPT_FORM => {
		message => 'too many equal signs(=) in value',
		entity => $_,
		full_entity => $value,
	    }) if @x > 2;
	    Bivio::Die->throw(CORRUPT_FORM => {
		message => 'missing key value (nothing before =)',
		entity => $_,
		full_entity => $value,
	    }) unless defined($x[0]) && length($x[0]);
	}
	@x == 1 ? (@x, undef) : @x;
	} split(/[\&\;]/, defined($value) ? $value : ''),
    )};
}

sub unescape_uri {
    my(undef, $value) = @_;
    return URI::Escape::uri_unescape($value);
}

sub unescape {
    my(undef, $text) = @_;
    return defined($text) ? scalar(HTML::Entities::decode($text)) : '';
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
