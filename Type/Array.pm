# Copyright (c) 2000,2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Array;
use strict;
use Bivio::Base 'Bivio::Type';
use Bivio::Die;

# C<Bivio::Type::Array> is a collection of array utilities and
# a string representable type.  Not all conversions are supported.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub bsearch_numeric {
    # (proto, array_ref, int) : array
    # Searches for I<to_find> in I<values> and returns an array
    # of the result and nearest key.
    my(undef, $key, $array) = @_;
    my($upper) = $#$array;
    my($lower) = 0;
    my($middle);
    my($i);
    while ($lower <= $upper) {
	my($cmp) = $array->[$middle = int(($lower+$upper)/2)]
		<=> $key;
	if ($cmp > 0) {
	    $upper = $middle - 1;
	}
	elsif ($cmp < 0) {
	    $lower = $middle + 1;
	}
	else {
	    # Return success and exact match
	    return (1, $middle);
	}
    }
    # Return failure and "neighbor" match
    return (0, $middle);
}

sub from_literal {
    # (proto, string) : undef
    # Splits on commas surround by any amount of whitespace.
    my($proto, $value) = @_;
    return $value
	? [split(/\s*,\s*/, $value)]
	: undef;
}

sub from_sql_column {
    # (proto, string) : array_ref
    # Splits on $; and returns an array_ref (sometimes empty).
    my(undef, $param) = @_;
    return defined($param) ? [split(/$;/, $param)] : [];
}

sub get_width {
    # (proto) : int
    # Returns 4000.
    return 4000;
}

sub to_literal {
    # (proto, array_ref) : string
    # Returns printable string.
    my($proto, $value) = @_;
    return join(', ', $value ? @$value : ());
}

sub to_query {
    # (proto, any) : string
    # B<NOT SUPPORTED>
    Bivio::Die->die('not supported');
}

sub to_sql_param {
    # (proto, array_ref) : string
    # Returns a string from the array_ref.  Dies if the value
    # contains $;.
    my(undef, $param_value) = @_;
    # May be the empty string, which is same as C<undef>
    return $param_value ? join($;, map {
	Bivio::Die->die($param_value, ': contains $; in an element')
		    if index($_, $;) >= $[;
	$_;
    } @$param_value) : undef;
}

sub to_sql_param_list {
    # (self, array_ref) : array_ref
    # Not implemented.
    die('not implemented');
}

sub to_uri {
    # (proto, any) : string
    # B<NOT SUPPORTED>
    Bivio::Die->die('not supported');
}

sub to_xml {
    # (proto, any) : string
    # B<NOT SUPPORTED>
    Bivio::Die->die('not supported');
}

1;
