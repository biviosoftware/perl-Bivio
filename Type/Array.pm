# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Array;
use strict;
$Bivio::Type::Array::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

C<Bivio::Type::Array> is a collection of array utilities.  It may
grow into a real type.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="bsearch_numeric"></a>

=head2 bsearch_numeric(array_ref values, int to_find) : array

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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
