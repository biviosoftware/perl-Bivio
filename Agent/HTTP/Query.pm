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

=head2 format(hash_ref query) : string

Returns the string version of the query.
Returns C<undef> if I<query> is C<undef>.

=cut

sub format {
    my(undef, $query) = @_;
    return undef unless $query;
    my($res);
    foreach my $k (keys(%$query)) {
	$res .= Bivio::Util::escape_uri($k).'='
		.Bivio::Util::escape_uri($query->{$k}).'&';
    }
    chop($res);
    return $res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
