# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Form;
use strict;
$Bivio::Agent::HTTP::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Form - parses incoming form data

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Form;
    Bivio::Agent::HTTP::Form->parse(Bivio::Agent::Request req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::HTTP::Form::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Form> parses an incoming form.
The request must have a I<form_model> attribute.  Handles both
C<application/x-www-form-urlencoded> and C<multipart/form-data>
(RFC 1867).

A form is a hash_ref.  The name of the field is the key.  The
value is either a scalar or a hash_ref.  A string is returned
in the "normal" case, i.e. non-file fields.  A hash_ref is returned
in the file field case or with forms which contain file fields
(see FormModel::_parse_cols for handling).  This is tightly coupled with
L<Bivio::Type::FileField|Bivio::Type::FileField>.  The hash_ref
contains the attributes: name, content_type, filename, and content.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Ext::ApacheConstants;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
# Taken from RFC1521.  NOT the same as 822_ATOM, btw.
my($_TOKEN) = '([^][()<>@,;:\\\\"/?=\\000-\\040\\177-\\377]+)';
# This is the same as Mail::RFC822::QUOTED_STRING, except
# we parse out the surrounding quotes.
#my($_QUOTED_STRING) = '"((?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';

=head1 METHODS

=cut

=for html <a name="parse"></a>

=head2 parse(Bivio::Agent::Request req)

Parses the input form.  Handles file fields.

B<Call before executing any DB transactions.>  Otherwise, may
get hanging transactions.  No way to hit database.

=cut

sub parse {
    my(undef, $req) = @_;
    my($r) = $req->get('r');

    # Only accept forms via POST
    return undef unless $r->method_number() eq Bivio::Ext::ApacheConstants::M_POST();

    # Check content type
    my($ct) = $r->header_in('Content-Type');
    if (defined($ct)) {
	if ($ct =~ /^\s*application\/x-www-form-urlencoded/i) {
	    # Let Apache do the parsing for us.  There is a bug
	    # here if the data isn't properly formatted.  Returns a
	    # odd number of elements in the hash.  Could fix it, but
	    # no sense slinging the data around.
	    return {$r->content()};
	}
	elsif ($ct =~ /^\s*multipart\/form-data/i) {
	    return _parse($req, $r);
	}
    }

    Bivio::IO::Alert->warn('unknown form Content-Type: ', $ct);
    return undef;
}

#=PRIVATE METHODS

# _parse(Bivio::Agent::HTTP::Request req, Apache r) : hash_ref
#
# Returns the parsed multipart/form-data.  See RFC1867 for a spec.
#
sub _parse {
    my($req, $r) = @_;
    my($max_field_size) = $req->get('form_model')->MAX_FIELD_SIZE;

#TODO: This may not be correct although it should be.
    my($len) = $r->header_in('Content-Length');
    if ($len) {
	$req->throw_die('CORRUPT_FORM',
		{message => 'negative Content-Length', entity => $len})
		if $len < 0;
    }
    else {
	$req->throw_die('CORRUPT_FORM', 'Content-Length: not set or zero');
    }
    _trace('Content-Length=', $len) if $_TRACE;

    # Assume the boundary begins with the first -- line
    # Until it gets all the bytes to read
    my($buf) = '';
    my($line, $boundary);

    # Get the boundary.  Should be in the first 10 lines!
#TODO: Probably should check that it matches Content-Type's boundary...
    for (my $i = 10; $i > 0; $i--) {
	# Read the header
	last unless _parse_header_line($req, $r, \$buf, \$len, \$line);
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
	my($field) = _parse_header($req, $r, \$buf, \$len);
	last unless defined($field);

	# Parse the content.
	my($content) = _parse_content($req, $r, \$buf, \$len, $boundary);

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

        Bivio::IO::Alert->warn('buffer length < 2, buf="', $buf, '"')
                    if (length($buf) < 2);

	# Parse the trailing \r\n
	next if $buf =~ s/^\r\n//;

	# Parse the closing boundary
	last if $buf =~ s/^--//;

        # Add more info re the corrupt form problem
        Bivio::IO::Alert->warn('Form contents so far=', $form);
        Bivio::IO::Alert->warn('Last field=', $field);
        Bivio::IO::Alert->warn('Last field content=', $$content);
        Bivio::IO::Alert->warn('Remaining buffer length=', length($buf));
        Bivio::IO::Alert->warn('Remaining buffer="', $buf, '"');
	$req->throw_die('CORRUPT_FORM',
		{message => 'invalid encapsulation or closing boundary',
		    entity => substr($buf, 0, 20)});
    }
    $req->throw_die('CLIENT_ERROR',
	    'client interrupt or timeout while reading form-data')
	    if $r->connection->aborted();

    # Return undef if form is empty, easier checking in FormModel
    return %$form ? $form : undef;
}

# _parse_content(Bivio::Agent::Request req, Apache r, scalar_ref buf, int_ref len, string boundary) : scalar_ref
#
# Returns the content as a scalar ref.
#
sub _parse_content {
    my($req, $r, $buf, $len, $boundary) = @_;

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
	my($j) = $$len < 0x10000 ? $$len : 0x10000;

	# read appends to buffer
	_read($r, \$value, $j, $req);
	$$len -= $j;
    }
    return;
}

# _parse_header(Bivio::Agent::Request req, Apache r, scalar_ref buf, int_ref len) : any
#
# Returns a string if it is a "simple" value, i.e. not a file.  Otherwise,
# returns a hash_ref with the header values.  Returns undef if no header
# is found.
#
sub _parse_header {
    my($req, $r, $buf, $len) = @_;
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
	else {
	    Bivio::IO::Alert->warn('unexpected field: ', $h);
	}
    }

    $req->throw_die('CORRUPT_FORM', {message => 'field missing "name" attribute',
	field => $field})
	    unless defined($field->{name});
    return $field;
}

# _parse_header_line(Bivio::Agent::Request req, Apache r, scalar_ref buf, int_ref len, scalar_ref line) : boolean
#
# Returns the next line.   This should only be used for reading mime headers.
# We blow up if the mime header is too large.
#
# $$len ignored if zero.
#
sub _parse_header_line {
    my($req, $r, $buf, $len, $line) = @_;
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
	my($i) = $$len < 0x400 ? $$len : 0x400;

	# Read appends to buffer
	_read($r, $buf, $i, $req);
	$$len -= $i;

	# Got something, adjust values and see if we have a line
	if ($$buf =~ s/^(.*)\r\n//) {
	    $$line = $1;
	    return 1;
	}
    }
    $req->throw_die('CORRUPT_FORM', 'header too long');
}

# _read(Apache r, string_ref buf, int len, Bivio::Agent::Request req)
#
# Reads or dies
#
sub _read {
    my($r, $buf, $len, $req) = @_;
    _trace('_read_len=', $len) if $_TRACE;
    $r->read($$buf, $len) || $req->throw_die('CLIENT_ERROR', 'read error');
    $req->throw_die('CLIENT_ERROR', 'buffer undefined after read')
	    unless defined($$buf);
}

=head1 SEE ALSO

RFC2616 (HTTP/1.1), RFC1945 (HTTP/1.0), RFC1867 (multipart/form-data),
RFC2109 (Cookies), RFC1806 (Content-Disposition), RFC1521 (MIME)

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
