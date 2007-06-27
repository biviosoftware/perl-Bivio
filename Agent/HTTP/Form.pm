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
	my($q) = $req->unsafe_get('query');
	return undef
	    unless $q && $q->{$req->FORM_IN_QUERY_FLAG};
	$req->put(query => {});
	return $q;
    }
    my($ct) = $r->header_in('Content-Type');
    if (defined($ct)) {
	if ($ct =~ /^\s*application\/x-www-form-urlencoded/i) {
            my(@form) = Apache::parse_args(1, ${$req->get_content});
	    push(@form, '')
		if int(@form) % 2;
            my($form) = {@form};
            $req->throw_die(CLIENT_ERROR =>
                'client interrupt or timeout while reading form-data',
	    ) if $r->connection->aborted;
            return $form;
	}
	elsif ($ct =~ /^\s*multipart\/form-data/i) {
	    return _parse($req, $r);
	}
    }
    Bivio::IO::Alert->warn($ct, ': unknown form Content-Type');
    return undef;
}

sub _parse {
    my($req, $r) = @_;
    # Returns the parsed multipart/form-data.  See RFC1867 for a spec.
    my($max_field_size) = $req->get_or_default(
	'form_model', 'Bivio::Biz::FormModel',
    )->MAX_FIELD_SIZE;
    my($buf) = $req->get_content;
    $req->throw_die('CORRUPT_FORM', 'Content-Length: not set or zero')
	unless my $len = length($$buf);
    _trace('Content-Length=', $len) if $_TRACE;
    # Assume the boundary begins with the first -- line
    # Until it gets all the bytes to read
    my($line, $boundary);

    # Get the boundary.  Should be in the first 10 lines!
#TODO: Probably should check that it matches Content-Type's boundary...
    for (my $i = 10; $i > 0; $i--) {
	# Read the header
	last unless _parse_header_line($req, $r, $buf, \$len, \$line);
	if ($line =~ /^--/) {
	    $boundary = "\r\n".$line;
	    last;
	}
    }
    $req->throw_die('CORRUPT_FORM', 'no starting boundary line')
	    unless ($boundary);

    # Loop over the fields.
    my($form) = {};
    while (1) {
	my($field) = _parse_header($req, $r, $buf, \$len);
	last unless defined($field);

	# Parse the content.
	my($content) = _parse_content($req, $r, $buf, \$len, $boundary);

	if (int(keys(%$field)) > 1) {
	    # Complex field
	    # If there is an error parsing, we don't save the content
	    $field->{content} = $content unless $field->{error};
	    $form->{$field->{name}} = $field;
	}
	elsif (length($$content) > $max_field_size) {
	    # Simple field is too large
	    $field->{error} = Bivio::TypeError::TOO_LONG();
	    $form->{$field->{name}} = $field;
	}
	else {
	    # Convert to simple field for ease of checking in FormModel
	    $form->{$field->{name}} = $$content;
	}
        _read($r, $buf, \$len, 0x10000, $req)
                if $len && (length($$buf) < 2);

	# Parse the trailing \r\n
	next if $$buf =~ s/^\r\n//;

	# Parse the closing boundary
	last if $$buf =~ s/^--//;

	$req->throw_die('CORRUPT_FORM',
		{message => 'invalid encapsulation or closing boundary',
		    entity => substr($$buf, 0, 20)});
    }
    $req->throw_die('CLIENT_ERROR',
	    'client interrupt or timeout while reading form-data')
	    if $r->connection->aborted();

    # Return undef if form is empty, easier checking in FormModel
    return %$form ? $form : undef;
}

sub _parse_content {
    my($req, $r, $buf, $len, $boundary) = @_;
    # Returns the content as a scalar ref.

    # We use a separate scalar instance to avoid a copy of the bulk
    # of the data.  There will always be a copy, but max size is
    # 0x1000 (see below), the size of the chunks we read.
    my($value) = $$buf;

    # Read the content.  First character of $value is the content.
    # We must find the next boundary and strip it out.  Returning
    # the left as the content and the right in $$buf (to be parsed).
    my($last_check) = 0;
    while (1) {
	my($i) = index($value, $boundary, $last_check);
	if ($i >= 0) {
	    # Found boundary: Save data after boundary
	    $$buf = substr($value, $i + length($boundary));

	    # Trim value before boundary and return content
	    substr($value, $i) = '';
	    return \$value;
	}
	# Pick up where we left off.  Don't check entire buffer
	# each time.
	$last_check = length($value) - length($boundary);

	# Read some pretty big chunks now (as opposed to parse_header_line),
	# because we didn't hit # it in a "short" field of thousand bytes, so
	# likely to be a file.
 	$req->throw_die('CORRUPT_FORM', 'Attempt to read past Content-Length')
                unless $$len;

	# read appends to buffer
	_read($r, \$value, $len, 0x10000, $req);
    }
    return;
}

sub _parse_header {
    my($req, $r, $buf, $len) = @_;
    # Returns a string if it is a "simple" value, i.e. not a file.  Otherwise,
    # returns a hash_ref with the header values.  Returns undef if no header
    # is found.
    my(@header);
    my($line);

    # Read the lines first, unfolding as we go
    while (1) {
	unless (_parse_header_line($req, $r, $buf, $len, \$line)) {
	    return undef unless @header;
	    $req->throw_die('CORRUPT_FORM', 'header without a body');
	}
	last unless length($line);
	if ($line =~ s/^\s+/ /) {
	    $req->throw_die('CORRUPT_FORM', 'leading white space in header')
		    unless @header;
	    $header[0] .= $line;
	}
	else {
	    push(@header, $line);
	}
    }

    # Interpret the mime header fields.  We only accept a few and
    # ignore the rest (with a warning!).
    my($field) = {};
    while (@header) {
	my($h) = pop(@header);
	if ($h =~ s/^Content-Disposition:\s*//i) {
	    # Must be included always
	    $req->throw_die('CORRUPT_FORM', {'Content-Disposition' => $h})
		    unless $h =~ s/^form-data\s*//;

	    # Parse each of the keywords
	    while ($h =~ s/^;\s*$_TOKEN\s*=\s*//i) {
		my($attr) = lc($1);

		# According to RFC822 all quotes and backslashes must be
		# escaped (quoted-pair) and other characters can be to.
		# The following handles what IE and NS do: they don't
		# escape, so values come through like filename="y".txt"
		# (the quote after the y should be escaped). We only
		# unescape backslash and quote, because the browsers pass
		# \ without escaping and therefore we can't just do
		# s/\\(.)/$1/g;

		if ($h =~ s/^\"(.*?)\"\s*;\s*/;/o
			|| $h =~ s/^\"(.*)\"\s*$//o
			|| $h =~ s/^$_TOKEN\s*//o) {
		    my($value) = $1;

		    # replace \\ with \ and \" with "
		    $value =~ s/\\\\/\\/g;
		    $value =~ s/\\\"/\"/g;
		    $field->{$attr} = $value;
		}
		else {
		    $req->throw_die('CORRUPT_FORM',
			    {'Content-Disposition' => "$attr=$h",
				message => 'invalid attribute syntax'});
		}
	    }
	}
	elsif ($h =~ s/^Content-Type:\s*//i) {
	    # We don't handle multipart/mixed.  Browsers may use
	    # this to send multiple files for a single field.  Our
	    # forms don't handle this.
	    if ($h =~ /multipart\/mixed/i) {
		$field->{error} = 'FORM_DATA_MULTIPART_MIXED';
		_trace('Content-Type:', $h) if $_TRACE;
	    }
	    else {
		$field->{content_type} = $h;
	    }
	}
	elsif ($h =~ s/^Content-Transfer-Encoding:\s*//i) {
	    # Really shouldn't get here, but just in case, so we
	    # don't corrupt user data.
	    $req->throw_die('CORRUPT_FORM',
		    {message => 'invalid encoding must be 8bit or binary',
			'Content-Transfer-Encoding' => $h})
		    unless $h =~ /^(?:8bit|binary)\b/i;
	    _trace('Content-Transfer-Encoding: ', $h) if $_TRACE;
	}
        elsif ($h =~ /^Content-Length:/i) {
            # ignore this, included by HTTP::Request only
            # the content is being parsed using the boundary
        }
	else {
	    Bivio::IO::Alert->warn('unexpected field: ', $h);
	}
    }

    $req->throw_die('CORRUPT_FORM', {
        message => 'field missing "name" attribute',
	field => $field,
    }) unless defined($field->{name});
    return $field;
}

sub _parse_header_line {
    my($req, $r, $buf, $len, $line) = @_;
    # Returns the next line.   This should only be used for reading mime headers.
    # We blow up if the mime header is too large.
    #
    # $$len ignored if zero.
    if ($$buf =~ s/^(.*)\r\n//) {
	$$line = $1;
	return 1;
    }

    # We try to find a line by reading 10 times.  If this fails, the
    # client has sent a bogus header (> 10240 bytes on one line).
    for (my $j = 10; $j > 0; $j--) {
 	$req->throw_die('CORRUPT_FORM', 'Attempt to read past Content-Length')
                unless $$len;
	# 1000 bytes should hit the header and then some
	_read($r, $buf, $len, 0x400, $req);

	# Got something, adjust values and see if we have a line
	if ($$buf =~ s/^(.*)\r\n//) {
	    $$line = $1;
	    return 1;
	}
    }
    $req->throw_die('CORRUPT_FORM', 'header too long');
}

sub _read {
    my($r, $buf, $len, $read_max, $req) = @_;
    # Reads or dies.  Appends to $$buf.
    my($read_bytes) = $$len < $read_max ? $$len : $read_max;
    # Newer mod_perl requires offset param.  Older mod_perl ignores.
    $r->read($$buf, $read_bytes, length($$buf))
            || $req->throw_die('CLIENT_ERROR', 'read error');
    $req->throw_die('CLIENT_ERROR', 'buffer undefined after read')
	    unless defined($$buf);
    $$len -= $read_bytes;
    return;
}

1;
