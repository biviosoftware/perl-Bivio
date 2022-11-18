# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Form;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
b_use('IO.Trace');

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

our($_TRACE);
# Taken from RFC1521.  NOT the same as 822_ATOM, btw.
my($_TOKEN) = '([^][()<>@,;:\\\\"/?=\\000-\\040\\177-\\377]+)';
# This is the same as Mail::RFC822::QUOTED_STRING, except
# we parse out the surrounding quotes.
#my($_QUOTED_STRING) = '"((?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';
my($_TOO_LONG) = b_use('Bivio.TypeError')->TOO_LONG;
my($_FORM_DATA_MULTIPART_MIXED)
    = b_use('Bivio.TypeError')->FORM_DATA_MULTIPART_MIXED;
my($_HTML) = b_use('Bivio.HTML');
my($_JSON) = b_use('MIME.JSON');

sub parse {
    my(undef, $req, $options) = @_;
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
    my($ct) = lc($r->header_in('content-type') || '');
    $ct =~ s/;.*//;
    $ct =~ s/\s//g;
    foreach my $x (
        [qr{^\s*application/x-www-form-urlencoded}, \&_parse_url],
        [qr{^\s*multipart/form-data}, \&_parse_multipart],
        [qr{^\s*application/json}, \&_parse_json],
    ) {
        _trace('content-type=', $ct) if $_TRACE;
        next
            unless $ct =~ $x->[0];
        my($res) = $x->[1]->($req, $r, $options);
        $res->{b_use('Biz.FormModel')->CONTENT_TYPE_FIELD} = $ct;
        return $res;
    }
    b_warn($ct, ': unknown Content-Type');
    return undef;
}

sub _err {
    my($req, $msg, $entity) = @_;
    $req->throw_die(CORRUPT_FORM => {
        message => $msg,
        entity => $entity,
    });
}

sub _parse_json {
    my($req) = @_;
    $req->put_req_is_json;
    return $_JSON->from_text($req->get_content);
}

sub _parse_multipart {
    my($req, $r, $options) = @_;
    # Returns the parsed multipart/form-data.  See RFC1867 for a spec.
    my($max_field_size)        =
        ($options || {})->{max_field_size}
        || ($req->unsafe_get('form_model') || b_use('Biz.FormModel'))
            ->MAX_FIELD_SIZE;
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
        my($field) = _parse_multipart_headers($buf, $req);
         _err($req, 'missing form boundary: ' . $boundary, $buf)
            unless (my $i = index($$buf, $boundary)) >= 0;
        my($content) = substr($$buf, 0, $i);
        substr($$buf, 0, $i + length($boundary)) = '';
        my($value) = keys(%$field) > 1 ? {
            %$field,
            $field->{error} ? () : (content => \$content),
        } : length($content) > $max_field_size ? {
            %$field,
            error => $_TOO_LONG
        } : $content;
        my($name) = $field->{name};
        if (defined($form->{$name})) {
            $form->{$name} = [$form->{$name}]
                unless ref($form->{$name}) eq 'ARRAY';
            push(@{$form->{$name}}, $value);
        }
        else {
            $form->{$name} = $value;
        }
        next if $$buf =~ s/^\r\n//s;
        last if $$buf =~ s/^--//s;
        _err($req, 'invalid encapsulation or closing boundary', $buf);
    }
    return $form;
}

sub _parse_multipart_headers {
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
                $field->{error} = $_FORM_DATA_MULTIPART_MIXED;
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
            b_warn($key, ': unexpected header field; headers=', $headers);
        }
    }
    _err($req, 'field missing "name" attribute', $field)
        unless defined($field->{name});
    return $field;
}

sub _parse_url {
    my($req) = @_;
    return $_HTML->parse_www_form_urlencoded(${$req->get_content});
}

1;
