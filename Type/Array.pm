# Copyright (c) 2000,2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Array;
use strict;
$Bivio::Type::Array::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Array::VERSION;

=head1 NAME

Bivio::Type::Array - array utilities, not a true type

=head1 SYNOPSIS

    use Bivio::Type::Array;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::Array::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::Array> is a collection of array utilities and
a string representable type.  Not all conversions are supported.

=cut

#=IMPORTS
use Bivio::Die;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="bsearch_numeric"></a>

=head2 static bsearch_numeric(array_ref values, int to_find) : array

Searches for I<to_find> in I<values> and returns an array
of the result and nearest key.

=cut

sub bsearch_numeric {
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

=for html <a name="from_literal"></a>

=head2 static from_literal(string value)

B<NOT SUPPORTED.>

=cut

sub from_literal {
    Bivio::Die->die('not supported');
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(string param) : array_ref

Splits on $; and returns an array_ref (sometimes empty).

=cut

sub from_sql_column {
    my(undef, $param) = @_;
    return defined($param) ? [split(/$;/, $param)] : [];
}

=for html <a name="get_width"></a>

=head2 static get_width() : int

Returns 4000.

=cut

sub get_width {
    return 4000;
}

=for html <a name="to_literal"></a>

=head2 static to_literal(array_ref value) : string

Returns printable string.

=cut

sub to_literal {
    my(undef, $value) = @_;
    return join(', ', $value ? @$value : ());
}

=for html <a name="to_query"></a>

=head2 static static to_query(any value) : string

B<NOT SUPPORTED>

=cut

sub to_query {
    Bivio::Die->die('not supported');
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(array_ref param_value) : string

Returns a string from the array_ref.  Dies if the value
contains $;.

=cut

sub to_sql_param {
    my(undef, $param_value) = @_;
    # May be the empty string, which is same as C<undef>
    return $param_value ? join($;, map {
	Bivio::Die->die($param_value, ': contains $; in an element')
		    if index($_, $;) >= $[;
	$_;
    } @$param_value) : undef;
}

=for html <a name="to_uri"></a>

=head2 static to_uri(any value) : string

B<NOT SUPPORTED>

=cut

sub to_uri {
    Bivio::Die->die('not supported');
}

=for html <a name="to_xml"></a>

=head2 static to_xml(any value) : string

B<NOT SUPPORTED>

=cut

sub to_xml {
    Bivio::Die->die('not supported');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000,2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
