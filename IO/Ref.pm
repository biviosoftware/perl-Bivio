# Copyright (c) 2001 bivio Software Artisans, Inc.  All Rights reserved.
# $Id$
package Bivio::IO::Ref;
use strict;
$Bivio::IO::Ref::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::Ref::VERSION;

=head1 NAME

Bivio::IO::Ref - manipulate references

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::Ref;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Ref::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::Ref> manipulates references.

=cut

#=IMPORTS
use Data::Dumper ();
use Bivio::IO::Alert;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="nested_equals"></a>

=head2 nested_equals(any left, any right) : boolean

Returns true if I<left> is structurally equal to I<right>, i.e. the contents of
all the data.

B<Does not handle cyclic data structures.>

=cut

sub nested_equals {
    my($proto, $left, $right) = @_;
    return 0 unless defined($left) eq defined($right);
    return 1 unless defined($left);

    # References must match exactly or we've got a problem
    return 0 unless ref($left) eq ref($right);

    # Scalar
    return $left eq $right ? 1 : 0 unless ref($left);

    if (ref($left) eq 'ARRAY') {
	return 0 unless int(@$left) == int(@$right);
	for (my($i) = 0; $i <= $#$left; $i++) {
	    return 0
		unless $proto->nested_equals($left->[$i], $right->[$i]);
	}
	return 1;
    }
    if (ref($left) eq 'HASH') {
	my(@e_keys) = sort(keys(%$left));
	my(@a_keys) = sort(keys(%$right));
	return 0
	    unless $proto->nested_equals(\@e_keys, \@a_keys);
	foreach my $k (@e_keys) {
	    return 0
		unless $proto->nested_equals($left->{$k}, $right->{$k});
	}
	return 1;
    }
    return $proto->nested_equals($$left, $$right)
	if ref($left) eq 'SCALAR';

    # blessed ref: Check if can equals and compare that way
    return $left->equals($right) ? 1 : 0
	if UNIVERSAL::can($left, 'equals');

    # CODE, GLOB, Regex, and blessed references should always be equal exactly
    return $left eq $right ? 1 : 0;
}

=for html <a name="to_scalar_ref"></a>

=head2 to_scalar_ref(string scalar) : scalar_ref

DEPRECATED: Use \('bla').

Returns its argument as a scalar_ref.

=cut

sub to_scalar_ref {
    my(undef, $scalar) = @_;
    return \$scalar;
}

=for html <a name="to_short_string"></a>

=head2 to_short_string(any value) : string

Returns a string summary of the ref.  Uses
L<Bivio::IO::Alert::format_args|Bivio::IO::Alert/"format_args">,
but doesn't include ending newline.

=cut

sub to_short_string {
    my(undef, $value) = @_;
    my($res) = Bivio::IO::Alert->format_args($value);
    chomp($res);
    return $res;
}

=for html <a name="to_string"></a>

=head2 static to_string(any ref, integer max_depth) : string_ref

Converts I<ref> into a string_ref.  The string is formatted "tersely"
using C<Data::Dumper>.

=cut

sub to_string {
    my(undef, $ref, $max_depth) = @_;
    my($dd) = Data::Dumper->new([$ref]);
    $dd->Indent(1);
    $dd->Terse(1);
    $dd->Deepcopy(1);
    $dd->Maxdepth($max_depth)
	if defined $max_depth;
    my($res) = $dd->Dumpxs();
    return \$res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
