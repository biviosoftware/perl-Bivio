# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Query;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
use Bivio::HTML;

my($_HTML) = b_use('Bivio.HTML');
my($_LQ) = b_use('SQL.ListQuery');
my($_U) = b_use('Bivio.UNIVERSAL');
my($_A);

sub format {
    # (proto, hash_ref) : string
    # Returns the string version of the query.  Returns C<undef> if I<query> is
    # C<undef>.  Attributes of the form C<ListQuery.>I<name> will be looked up
    # with L<Bivio::ListQuery::to_char|Bivio::ListQuery/"to_char">.
    my(undef, $query, $req) = @_;
    return undef
	unless $query;
    if (exists($query->{acknowledgement})) {
	($_A ||= b_use('Action.Acknowledgement'))
	    ->save_label(delete($query->{acknowledgement}), $req, $query);
	return undef
	    unless %$query;
    }
    my($res) = '';
    # Always format the keys in the same order
    foreach my $k (sort(keys(%$query))) {
	my($v) = $query->{$k};
	$k = $_LQ->to_char($k)
	    if $k =~ s/^ListQuery\.//;
	$res .= $_HTML->escape_query($k)
	    . '='
	    # Sometimes the query value is not defined.  It may
	    # be a corrupt query, but shouldn't blow up.
	    . $_HTML->escape_query(
		ref($v)
		? $_U->is_blesser_of($v) && $v->can('as_query')
		? $v->as_query
		: $req->isa('Bivio::Test::Request')
		? "$v"
		: b_die($k, '=', $v, ': query value is a reference')
		: defined($v)
		? $v
		: '',
	    ) . '&';
    }
    chop($res);
    return $res;
}

sub parse {
    # (proto, string) : hash_ref
    # Returns a hash_ref for the query string.  Returns C<undef> if
    # string not defined.
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
	push(@v, $_HTML->unescape_query($k),
		defined($v) ? $_HTML->unescape_query($v) : undef);
    }

    # No valid elements?
    return undef unless @v;

    # Return the hash
    return {@v};
}

sub _correct {
    # (string, string) : string
    # Corrects the URI using specified unescape method
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
    return $_HTML->$method($literal);
}

1;
