# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::String;
use strict;
$Bivio::Type::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::String - base class for all string types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::String;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::String::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::String> is the base class for all string types.
It is currently a placeholder.

=cut

#=IMPORTS
use Text::Tabs;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="compare"></a>

=for html <a name="compare"></a>

=head2 static compare(string left, string right) : int

Returns the string comparison (cmp) of I<left> to I<right>.

=cut

sub compare {
    my(undef, $left, $right) = @_;
    return $left cmp $right;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if the string is empty.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value) && length($value);
    return $value;
}

=for html <a name="wrap_lines"></a>

=head2 wrap_lines(string value, int width) : string

=head2 wrap_lines(string_ref value, int width) : string

Returns I<value> with lines wider than I<width> wrapped.
The default value for I<width> is 72.

=cut

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

#=PRIVATE METHODS

# _wrap_line(array_ref formatted, string_ref line, int indent, int width)
#
# - find I<line> indentation
# - search for white space around I<width>
#   If found, break line and push left side to I<@formatted>,
#      re-indent the remainding (right) part of the line
# - Dont break line if no white space found or if line is quoted
#
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
