# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::Bytes;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Format';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_widget_value {
    my($self, $size) = @_;
    return '' unless defined($size) && length($size);
    return '0 KB' if $size == 0;
    $size = _format($size, "%.0f");
    return '1 KB' unless $size;
    # less than 3 digits
    return $size . ' KB'
	if $size < 1000;
    return _format($size, "%.1f") . ' MB';
}

sub _format {
    my($v, $f) = @_;
    $v = sprintf($f, $v / 1024.0);
    $v =~ s/\.0$//;
    return $v;
}

1;
