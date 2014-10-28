# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::TextArea;
use strict;
use Bivio::Base 'Type.Text';


sub LINE_WIDTH {
    return 60;
}

sub from_literal {
    my($proto, $value, $line_width) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
 	unless defined($value) && length($value);
    return (undef, Bivio::TypeError->TOO_LONG)
 	if length($value) > $proto->get_width;
    my($pref, $req);
    my($v);
    $v = _wrap_lines($proto, $value, $line_width || $proto->LINE_WIDTH)
	if defined($value)
        and $req = Bivio::Agent::Request->get_current
	and $pref = b_use('Model.RowTag')->new($req)
	    ->row_tag_get_for_auth_user('TEXTAREA_WRAP_LINES')
        and $pref;
    $v = $proto->canonicalize_charset(\$value)
	unless $v;
    return (undef, undef)
	unless $$v;
    $$v .= "\n"
	unless $$v =~ /\n$/;
    return $$v;
}

sub get_width {
    # Max size in browsers
    return 0xffff;
}

sub _wrap_lines {
    my($proto, $value, $width) = @_;
    $width = 72
	unless $width;
    my($lines) = [];
    my($formatted) = [];
    my($indent) = 0;
    foreach my $line (
	Text::Tabs::expand(
	    @{[split(
		/\n/,
		${$proto->canonicalize_charset($value)},
	    )]},
	),
    ) {
        $line =~ s/\s+$//;
        while (defined($line) && length($line) > $width) {
            _wrap_line($formatted, \$line, $indent, $width);
        }
        push(@$formatted, $line)
	    if defined($line);
    }
    return \(join("\n", @$formatted, ''));
}

sub _wrap_line {
    my($formatted, $line, $indent, $width) = @_;
    $$line =~ /(^\s*(|[\-\*])\s+)/;
    $indent = defined($1) ? substr($1, 0, $width) : '';
    my($white_pos) = rindex($$line, ' ', $width);
    $white_pos = index($$line, ' ', $width)
	if $white_pos < length($indent);
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
