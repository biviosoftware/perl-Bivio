# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::JoinHandler;
use strict;
use Bivio::Base 'Widget.Join';


sub get_html_field_attributes {
    my($self) = shift;
    my($attrs_by_name) = {};

    foreach my $handler (@{$self->get('values')}) {
	my($str) = $handler->get_html_field_attributes(@_);

	while ($str) {
	    $str =~ s/^\s+(\w+)="([^"]+)"// || b_die('invalid pattern');
	    push(@{$attrs_by_name->{lc($1)} ||= []}, $2);
	}
    }
    return join('',
        map(" $_=\"" . join(';', @{$attrs_by_name->{$_}}) . '"',
	    sort(keys(%$attrs_by_name))));
}

1;
