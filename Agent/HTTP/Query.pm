# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Query;
use strict;
$Bivio::Agent::HTTP::Query::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Query - formats query strings

=head1 RELEASE SCOPE

bOP

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
use Bivio::HTML;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="format"></a>

=head2 static format(hash_ref query) : string

Returns the string version of the query.  Returns C<undef> if I<query> is
C<undef>.  Attributes of the form C<ListQuery.>I<name> will be looked up
with L<Bivio::ListQuery::to_char|Bivio::ListQuery/"to_char">.

=cut

sub format {
    my(undef, $query) = @_;
    return undef unless $query;
    my($res) = '';
    # Always format the keys the same way
    foreach my $k (sort(keys(%$query))) {
	my($v) = $query->{$k};
	$k = Bivio::SQL::ListQuery->to_char($k) if $k =~ s/^ListQuery\.//;
	$res .= Bivio::HTML->escape_query($k).'='
		# Sometimes the query value is not defined.  It may
		# be a corrupt query, but shouldn't blow up.
		.Bivio::HTML->escape_query(defined($v) ? $v : '').'&';
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
    $string = _correct('unescape_uri', $string)
	    if $string =~ /^(?:v=1%26|v%3d1)/i;

    # Some search engines don't unescape_html when parsing the page
    #   /pub/trez_talk/msg?v=1&amp;t=292100003&amp;o=0d1a2a
    $string = _correct('unescape', $string)
	    if $string =~ /&amp;\w=/;

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
	push(@v, Bivio::HTML->unescape_query($k),
		defined($v) ? Bivio::HTML->unescape_query($v) : undef);
    }

    # No valid elements?
    return undef unless @v;

    # Return the hash
    return {@v};
}

#=PRIVATE METHODS

# _correct(string method, string literal) : string
#
# Corrects the URI using specified unescape method
#
sub _correct {
    my($method, $literal) = @_;
    my(@msg) = ('correcting query=', $literal);
    my($req) = Bivio::Agent::Request->get_current;
    if ($req) {
	my($r) = $req->get('r');
	push(@msg,
		', uri=', $req->unsafe_get('uri'),
		', referer=', $r ? $r->header_in('referer') : undef,
		', client_addr=', $req->unsafe_get('client_addr'),
		', user-agent=', $r ? $r->header_in('user-agent') : undef,
	       );
    }
    Bivio::IO::Alert->warn(@msg);
    return Bivio::HTML->$method($literal);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
