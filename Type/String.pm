# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::String;
use strict;
use Bivio::Base 'Bivio::Type';
use Text::Tabs;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub clean_and_trim {
    my($proto, $value) = @_;
    b_die('value must be no-zero length')
	unless defined($value) && length($value);
    $value .= $value
	while length($value) < $proto->get_min_width;
    return substr($value, 0, $proto->get_width);
}

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

sub get_min_width {
    return 0;
}

sub get_width {
    return 0x7fffffff;
}

sub to_camel_case {
    return _camel_case($_[1], ' ');
}

sub to_camel_case_identifier {
    return _camel_case($_[1], '');
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

sub _camel_case {
    my($value, $sep) = @_;
    return !$value ? $value
	: join($sep, map(ucfirst(lc($_)), split(/[\W_]+/, $value)));
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
