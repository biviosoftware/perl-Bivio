# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Query;
use strict;
$Bivio::Agent::HTTP::Query::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Query - formats query strings

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Query;
    Bivio::Agent::HTTP::Query->format($query);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::HTTP::Query::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Query> formats a hash_ref into a query string

=cut

#=IMPORTS
use Bivio::Util;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="format"></a>

=head2 static format(hash_ref query) : string

Returns the string version of the query.
Returns C<undef> if I<query> is C<undef>.

=cut

sub format {
    my(undef, $query) = @_;
    return undef unless $query;
    my($res) = '';
    foreach my $k (keys(%$query)) {
	$res .= Bivio::Util::escape_query($k).'='
		.Bivio::Util::escape_query($query->{$k}).'&';
    }
    chop($res);
    return $res;
}

=for html <a name="parse"></a>

=head2 static parse(string query) : hash_ref

Returns a hash_ref for the query string.  Returns C<undef> if
string not defined.

=cut

sub parse {
    my(undef, $string) = @_;

    # Empty?
    return undef unless defined($string);

    # Some search engines escape the query string incorrectly.
    #   /pub/trez_talk/msg?v=1%26t=332800003%26o=0d1a2a
    if ($string =~ /^(?:v=1%26|v%3d1)/i) {
	my($req) = Bivio::Agent::Request->get_current;
	if ($req) {
	    my($r) = $req->get('r');
	    Bivio::IO::Alert->warn('correcting query=', $string,
		    ', uri=', $req->unsafe_get('uri'),
		    ', referer=', $r ? $r->header_in('referer') : undef,
		    ', client_addr=', $req->unsafe_get('client_addr'),
		    ', user-agent=', $r ? $r->header_in('user-agent') : undef,
		   );
	}
	$string =~ Bivio::Util::unescape_uri($string);
    }

    # Split on & and then =
    my(@v);
    foreach my $item (split(/&/, $string)) {
	# While it isn't usual to have a query value with = literally,
	# it can happen and therefore we have the "2".
	my($k, $v) = split(/=/, $item, 2);

	# Avoid the lone "&=" case.  Totally mangled query element.
	next unless defined($k) && length($k);

	# $v may not be defined.  This is a malformed query, but
	# let's handle anyway.
	push(@v, Bivio::Util::unescape_uri($k),
		defined($v) ? Bivio::Util::unescape_uri($v) : undef);
    }

    # No valid elements?
    return undef unless @v;

    # Return the hash
    return {@v};
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
