# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::HTML;
use strict;
$Bivio::HTML::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::HTML::VERSION;

=head1 NAME

Bivio::HTML - simple support routines for HTML, e.g. escape

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::HTML;

=cut

use Bivio::UNIVERSAL;
@Bivio::HTML::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::HTML> implements simple support routines for HTML.
We also include URI routines here to avoid "micro-modules".

=cut

#=IMPORTS
use HTML::Entities ();

#=Variables
BEGIN {
    # Create routines dynamically.  We pass arguments explicitly, because
    # some of these modify their first argument if they are called in a
    # void context.
    if (exists($ENV{MOD_PERL})) {
	eval '
	    # Use Apache::Util because it is faster
	    use Apache ();
	    use Apache::Util ();
            # Protect Apache; SEGVs if not defined
	    sub escape {
		my(undef, $value) = @_;
		return Apache::Util::escape_html($value) if defined($value);
		Bivio::IO::Alert->warn("use of undefined value");
		return "";
	    }
	    sub escape_uri {
		my(undef, $value) = @_;
		return _extra_escape_uri(Apache::Util::escape_uri($value))
			if defined($value);
		Bivio::IO::Alert->warn("use of undefined value");
		return "";
	    }
	    sub unescape_uri {
		my(undef, $value) = @_;
		return Apache::unescape_url($value) if defined($value);
		Bivio::IO::Alert->warn("use of undefined value");
		return "";
	    }
	    1;
	' || die($@);
    }
    else {
        eval '
	    use URI::Escape ();
	    sub escape {
		my(undef, $value) = @_;
		$value = HTML::Entities::encode($value);
		return $value;
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
	    1;
	' || die($@);
    }
}

=head1 METHODS

=cut

=for html <a name="escape"></a>

=head2 static escape(string text) : string

Makes sure the string is safe for HTML.

=cut

$_ = <<'}'; # emacs
sub escape {
}

=for html <a name="escape_attr_value"></a>

=head2 escape_attr_value(string text) : string

Escapes an attribute.  Escaping quotes.

B<Netscape and IE seems to require that we escape the html inside the quotes
even though this isn't the standard.>

=cut

sub escape_attr_value {
    my($proto, $text) = @_;
    return $proto->escape($text);
}

=for html <a name="escape_query"></a>

=head2 static escape_query(string text) : string

Same as escape_uri except escapes '+' and '?' as well.

=cut

sub escape_query {
    my($proto, $text) = @_;
    $text = $proto->escape_uri($text);
    $text =~ s/\+/\%2B/g;
    $text =~ s/\?/\%3F/g;  #don't let this fall through the cracks
    return $text;
}

=for html <a name="escape_uri"></a>

=head2 static escape_uri(string text) : string

Returns the string escaped according to URI conventions.

=cut

$_ = <<'}'; # emacs
sub escape_uri {
}

=for html <a name="unescape"></a>

=head2 static unescape(string html) : string

Returns the unescaped HTML string.  See also L<escape|"escape">.

=cut

sub unescape {
    # we want to unescape, not decode
    my(undef, $text) = @_;
    $text =~ s/&amp;/&/g;
    $text =~ s/&quot;/"/g;
    $text =~ s/&lt;/</g;
    $text =~ s/&gt;/>/g;
    return $text;
}

=for html <a name="unescape_query"></a>

=head2 static unescape_query(string text) : string

Removes "+" from the query.  This is not done by unescape_uri.

=cut

sub unescape_query {
    my($proto, $value) = @_;
    $value =~ s/\+/ /g;
    return $proto->unescape_uri($value);
}

=for html <a name="unescape_uri"></a>

=head2 static unescape_uri(string text) : string

Converts a URI back to its original form.  Is the converse of
L<escape_uri|"escape_uri">.

=cut

$_ = <<'}'; # emacs
sub unescape_uri {
}

#=PRIVATE METHODS

# _extra_escape_uri(string v) : string
#
# Escapes & and = in URIs, because browsers don't do the right thing
# in quoted strings.  Unescape '/'s because they shouldn't be escaped.
#
sub _extra_escape_uri {
    my($v) = @_;
    $v =~ s/\=/%3D/g;
    $v =~ s/\&/%26/g;
    $v =~ s/%2F/\//g;
    return $v;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
