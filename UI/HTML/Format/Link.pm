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

=head2 static get_widget_value(any href) : string

=head2 static get_widget_value(any href, string site, any site_args, ...) : string

Returns an href, possibly as an /goto link.  If I<site> is specified,
must match one of the site implementations below.

href may be a L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> or it
may be a name of TaskId.

=cut

sub get_widget_value {
    my(undef, $href, $site) = (shift, shift, shift);
    my($tag);
    ($href, $tag) = &{\&{'_site_'.$site}}($href, @_)
	    if $site;
    return $href if _format_task(\$href);

    # Not an offsite uri?  Just return $href.
    return $href unless $href =~ /^\w+:/ || $tag;

    return Bivio::Agent::HTTP::Location->format_realmless(
	    Bivio::Agent::TaskId::CLIENT_REDIRECT(),
	   $tag)
	    .'?'
	    .Bivio::Biz::Action::ClientRedirect->QUERY_TAG()
	    .'='.Bivio::HTML->escape_query($href);
}

#=PRIVATE METHODS

# _format_task(string_ref href) : boolean
#
# Returns true if formatted as a task uri.
#
sub _format_task {
    my($href) = @_;
    if (ref($$href)) {
	Bivio::Die->die($$href, ': ref is not a TaskId')
		    unless UNIVERSAL::isa($$href, 'Bivio::Agent::TaskId');
    }
    elsif (Bivio::Agent::TaskId->is_valid_name($$href)) {
	$$href = Bivio::Agent::TaskId->$$href();
    }
    else {
	return 0;
    }
    # This will result in an "onsite" uri, but may have https:/ in front
    $$href = Bivio::Agent::Request->get_current->format_stateless_uri($$href);
    return 1;
}

# _site_advertizement(any uri, string tag) : string
#
# Returns its arguments.  You may pass a TASK as the uri.  If there
# is a tag, it will be return and used.
#
sub _site_advertizement {
    return @_;
}

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
