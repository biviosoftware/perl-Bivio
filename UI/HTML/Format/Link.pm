# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Link;
use strict;
$Bivio::UI::HTML::Format::Link::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Format::Link::VERSION;

=head1 NAME

Bivio::UI::HTML::Format::Link - formats an href adding a goto, if necessary

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format::Link;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Format>

=cut

use Bivio::UI::HTML::Format;
@Bivio::UI::HTML::Format::Link::ISA = ('Bivio::UI::HTML::Format');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format::Link> formats external hrefs as /goto
links.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 static get_widget_value(string href) : string

=head2 static get_widget_value(any href, string site) : string

Returns an href, possibly as an /goto link.  If I<site> is specified,
must match one of the site implementations below.

=cut

sub get_widget_value {
    my(undef, $href, $site) = @_;
    $href = &{\&{'_site_'.$site}}($href) if $site;
    return $href unless $href =~ /^\w+:/;
    return Bivio::Agent::HTTP::Location->format_realmless(
	    Bivio::Agent::TaskId::CLIENT_REDIRECT())
	    .'?'
	    .Bivio::Biz::Action::ClientRedirect->QUERY_TAG()
	    .'='.Bivio::HTML->escape_query($href);
}

#=PRIVATE METHODS

# _site_yahoo_quotes(array_ref ticker) : string
#
# Returns href for Yahoo Quotes site.
#
sub _site_yahoo_quotes {
    my($tickers) = @_;
    return 'http://quote.yahoo.com/q?d=v1&s='.
	    Bivio::HTML->escape_query(join(' ', @$tickers));
}

# _site_zacks_quotes(string ticker) : string
#
# Returns href for Zacks Quotes site.
#
sub _site_zacks_quotes {
    my($ticker) = @_;
    return 'http://lada.zacks.com/jmfr2/jmfr2_q.php3?t='
	    .Bivio::HTML->escape_query($ticker)
	    .'&top=2&sub=1&partner=BIVIO';
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
