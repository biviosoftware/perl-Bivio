# Copyright (c) 2000-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Link;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Format';

# C<Bivio::UI::HTML::Format::Link> formats external hrefs as /goto
# links.


sub get_widget_value {
    # (proto, any) : string
    # Returns an href, possibly as an /goto link.
    #
    # href may be a L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> or it
    # may be a name of TaskId.
    my($source, $href) = @_;
    return $href if _format_task(\$href);

    # Not an offsite uri?  Just return $href.
    return $href unless $href =~ /^\w+:/;

    return b_use('FacadeComponent.Task')->format_realmless_uri(
	Bivio::Agent::TaskId->CLIENT_REDIRECT, undef,
	$source->get_request)
	. '?' . Bivio::Biz::Action::ClientRedirect->QUERY_TAG
	. '=' . Bivio::HTML->escape_query($href);
}

sub _format_task {
    # (string_ref) : boolean
    # Returns true if formatted as a task uri.
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

1;
