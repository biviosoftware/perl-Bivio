# Copyright (c) 2000-2020 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format::Link;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Format';

sub get_widget_value {
    my($source, $href) = @_;
    _format_task(\$href);
    return $href;
}

sub _format_task {
    my($href) = @_;
    if (ref($$href)) {
        b_die($$href, ': ref is not a TaskId')
            unless UNIVERSAL::isa($$href, 'Bivio::Agent::TaskId');
    }
    elsif (Bivio::Agent::TaskId->is_valid_name($$href)) {
        $$href = Bivio::Agent::TaskId->$$href();
    }
    else {
        return;
    }
    # This will result in an "onsite" uri, but may have https:/ in front
    $$href = Bivio::Agent::Request->get_current->format_stateless_uri($$href);
    return;
}

1;
