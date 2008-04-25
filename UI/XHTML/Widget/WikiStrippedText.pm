# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiStrippedText;
use strict;
use Bivio::Base 'XHTMLWidget.WikiText';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_on_render {
    my(undef, undef, $buffer) = @_;
    shift->SUPER::control_on_render(@_);
    $$buffer =~ s{<p(?: class="(?:b_)?prose")?>(.*?)</p>$}{$1}s;
    chomp($$buffer);
    return;
}

1;
