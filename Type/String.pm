# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::String;
use strict;
use Bivio::Base 'Bivio::Type';
use Text::Tabs;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub compare {
    my($proto, $left, $right) = @_;
    return $proto->compare_defined(
	defined($left) ? $left : '',
	defined($right) ? $right : '',
    );
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
	unless defined($value) && length($value);
    return (undef, Bivio::TypeError->TOO_LONG)
	if length($value) > $proto->get_width;
    return $value;
}

sub get_width {
    return 0x7fffffff;
}

sub wrap_lines {
    my($proto, $value, $width) = @_;
    $width = 72 unless $width;
    my(@lines) = (split /\n/, ref($value) ? $$value : $value);
    @lines = Text::Tabs::expand(@lines);
    my($formatted) = [];
    my($indent) = 0;
    foreach my $line (@lines) {
        $line =~ s/\s+$//;
        while (defined($line) && length($line) > $width) {
            _wrap_line($formatted, \$line, $indent, $width);
        }
        push(@$formatted, $line) if defined($line);
    }
    return join("\n", @$formatted, '');
}

sub _wrap_line {
    my($formatted, $line, $indent, $width) = @_;
    $$line =~ /(^\s*(|[\-\*])\s+)/;
    $indent = defined($1) ? substr($1, 0, $width) : '';
    my($white_pos) = rindex($$line, ' ', $width);
    $white_pos = index($$line, ' ', $width) if $white_pos < length($indent);
    # Line cannot be broken if no white-space found or quoted
    if ($white_pos == -1 || $$line =~ /^\s*[>]/) {
        push(@$formatted, $$line);
        undef($$line);
    }
    else {
        my($wrapped) = substr($$line, 0, $white_pos);
        push(@$formatted, $wrapped);
        $$line = substr($$line, $white_pos);
        $$line =~ s/^\s+/' ' x length($indent)/e;
    }
    return;
}

1;
