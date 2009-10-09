# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiTextTag;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ACCEPTS_CHILDREN {
    return 0;
}

sub assert_no_content {
    my(undef, $args) = @_;
    b_die($args->{content}, ': does not accept content')
        if defined($args->{content});
    return;
}

sub parse_args {
    my($proto, $expected_attrs, $args) = @_;
    my($attrs) = {%{$args->{attrs}}};
    foreach my $ea (@{[@$expected_attrs]}) {
	delete($attrs->{$ea});
    }
    if (%$attrs) {
	b_die($attrs, ': unexpected attributes passed to ', $args->{tag})
	    unless my $state = $args->{state};
	return $state->{proto}->render_error(
	    join(' ', sort(keys(%$attrs))),
	    "unexpected attributes passed to \@$args->{tag}",
	    $state,
	);
    }
    return ($proto, $args);
}

sub render_plain_text {
    return '';
}

1;
