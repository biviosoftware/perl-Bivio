# Copyright (c) 2000-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Array;
use strict;
use Bivio::Base 'Bivio.Type';

my($_S) = b_use('Type.String');

#TODO: This class is deprecated.  Use ArrayBase, StringArray, etc.

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

sub map_sort_map {
    my(undef, $name_op, $sort_op, $values) = @_;
    return [map(
        $_->[1],
        sort(
            {$sort_op->($a->[0], $b->[0])}
            map(
                [$name_op->($_), $_],
                @$values,
            ),
        ),
    )];
}

sub sort_unique {
    my(undef, $values) = @_;
    return []
        unless @$values;
    my($type) = ref($values->[0]) ? $values->[0] : $_S;
    my($seen) = {};
    return [sort(
        {$type->compare($a, $b)}
        grep(!$seen->{$type->to_literal($_)}++, @$values),
    )];
}

sub to_hash {
    my($self, $array, $value_or_op) = @_;
    $value_or_op = 1
        if @_ <= 2;
    return {
        ref($value_or_op) eq 'CODE'
            ? map(($_ => $value_or_op->($_)), @$array)
            : map(($_ => $value_or_op), @$array)
    };
}

sub to_json {
    b_die('not supported');
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
    b_die('not supported');
}

sub to_sql_param {
    # (proto, array_ref) : string
    # Returns a string from the array_ref.  Dies if the value
    # contains $;.
    my(undef, $param_value) = @_;
    # May be the empty string, which is same as C<undef>
    return $param_value ? join($;, map {
        b_die($param_value, ': contains $; in an element')
            if index($_, $;) >= 0;
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
    b_die('not supported');
}

sub to_xml {
    # (proto, any) : string
    # B<NOT SUPPORTED>
    b_die('not supported');
}

1;
