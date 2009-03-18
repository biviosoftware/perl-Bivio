# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Form;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::Ext::ApacheConstants;
use Bivio::IO::Trace;

# C<Bivio::Agent::HTTP::Form> parses an incoming form.
# The request must have a I<form_model> attribute.  Handles both
# C<application/x-www-form-urlencoded> and C<multipart/form-data>
# (RFC 1867).
#
# A form is a hash_ref.  The name of the field is the key.  The
# value is either a scalar or a hash_ref.  A string is returned
# in the "normal" case, i.e. non-file fields.  A hash_ref is returned
# in the file field case or with forms which contain file fields
# (see FormModel::_parse_cols for handling).  This is tightly coupled with
# L<Bivio::Type::FileField|Bivio::Type::FileField>.  The hash_ref
# contains the attributes: name, content_type, filename, and content.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
# Taken from RFC1521.  NOT the same as 822_ATOM, btw.
my($_TOKEN) = '([^][()<>@,;:\\\\"/?=\\000-\\040\\177-\\377]+)';
# This is the same as Mail::RFC822::QUOTED_STRING, except
# we parse out the surrounding quotes.
#my($_QUOTED_STRING) = '"((?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';

sub parse {
    my(undef, $req) = @_;
    my($r) = $req->get('r');
    my($m) = lc($r->method);
    unless ($m eq 'post') {
	return undef
	    unless $m eq 'get';
	my($q) = $req->unsafe_get('query');
	return undef
	    unless $q && $q->{$req->FORM_IN_QUERY_FLAG};
	$req->put(query => {});
	return $q;
    }
    my($ct) = $r->header_in('content-type') || '';
    return Bivio::HTML->parse_www_form_urlencoded(${$req->get_content})
	if $ct =~ /^\s*application\/x-www-form-urlencoded/i;
    return _parse($req, $r)
	if $ct =~ /^\s*multipart\/form-data/i;
    Bivio::IO::Alert->warn($ct, ': unknown Content-Type');
    return undef;
}

sub _err {
    my($req, $msg, $entity) = @_;
    $req->throw_die(CORRUPT_FORM => {
	message => $msg,
	entity => $entity,
    });
}

sub _parse {
    my($req, $r) = @_;
    # Returns the parsed multipart/form-data.  See RFC1867 for a spec.
    my($max_field_size) = $req->get_or_default(
	'form_model', 'Bivio::Biz::FormModel',
    )->MAX_FIELD_SIZE;
    my($buf) = $req->get_content;
    # We destroy content so we have to clear it here.
    $req->delete('content');
    _trace('length=', length($$buf)) if $_TRACE;
    _err($req, 'no starting boundary line', undef)
	unless $$buf =~ s/^(?:.*?\r\n)*?(--.*?)\r\n//s;
    my($boundary) = "\r\n$1";
    _trace('boundary=', $boundary) if $_TRACE;
    my($form) = {};
    while (1) {
	my($field) = _parse_headers($buf, $req);
 	_err($req, 'missing form boundary: ' . $boundary, $buf)
	    unless (my $i = index($$buf, $boundary)) >= 0;
	my($content) = substr($$buf, 0, $i);
	substr($$buf, 0, $i + length($boundary)) = '';
	$form->{$field->{name}} = keys(%$field) > 1 ? {
	    %$field,
	    $field->{error} ? () : (content => \$content),
	} : length($content) > $max_field_size ? {
	    %$field,
	    error => Bivio::TypeError->TOO_LONG
	} : $content;
	next if $$buf =~ s/^\r\n//s;
	last if $$buf =~ s/^--//s;
	_err($req, 'invalid encapsulation or closing boundary', $buf);
    }
    return $form;
}

sub _parse_headers {
    my($buf, $req) = @_;
    $req->throw_die(CORRUPT_FORM => {
	message => 'missing header separator',
	entity => $buf,
    }) unless $$buf =~ s/^(.*?)\r\n\r\n//s;
    my($headers) = $1;
    $headers =~ s/\r\n\s/ /sg;
    my($field) = {};
    foreach my $header (split(/\r\n/, $headers)) {
	my($key, $value) = split(/:\s*/s, $header, 2);
	$key = lc($key);
	_trace($key, ': ', $value) if $_TRACE;
	if ($key eq 'content-type') {
	    # LIMITATION: We don't handle multipart/mixed.  Browsers may use
	    # this to send multiple files for a single field.
	    if ($value =~ /multipart\/mixed/i) {
		$field->{error} = Bivio::TypeError->FORM_DATA_MULTIPART_MIXED;
		next;
	    }
	    $field->{content_type} = $value;
	}
	elsif ($key eq 'content-disposition') {
	    _err($req, 'invalid content-disposition', $value)
		unless $value =~ s/^form-data\s*//s;
	    while ($value =~ s/^;\s*$_TOKEN\s*=\s*//os) {
		my($attr) = lc($1);
		# According to RFC822 all quotes and backslashes must be
		# escaped (quoted-pair) and other characters can be to.
		# The following handles what IE and NS do: they don't
		# escape, so values come through like filename="y".txt"
		# (the quote after the y should be escaped). We only
		# unescape backslash and quote, because the browsers pass
		# \ without escaping and therefore we can't just do
		# s/\\(.)/$1/g;
		_err($req, $attr . ': invalid content-disposition attribute syntax', $value)
		    unless $value =~ s/^\"(.*?)\"\s*;\s*/;/s
		    || $value =~ s/^\"(.*)\"\s*$//s
		    || $value =~ s/^$_TOKEN\s*//os;
		my($v) = $1;
		$v =~ s/\\\\/\\/g;
		$v =~ s/\\\"/\"/g;
		$field->{$attr} = $v;
	    }
	}
	elsif ($key eq 'content-transfer-encoding') {
	    # Really shouldn't get here, but just in case, so we
	    # don't corrupt user data.
	    _err($req, 'invalid encoding must be 8bit or binary', $value)
		unless $value =~ /^(?:8bit|binary)\b/i;
	}
        elsif ($key ne 'content-length') {
	    Bivio::IO::Alert->warn($key, ': unexpected header field; headers=', $headers);
	}
    }
    _err($req, 'field missing "name" attribute', $field)
        unless defined($field->{name});
    return $field;
}

1;
