# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Align;
use strict;
$Bivio::UI::Align::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Align - html table alignments (north, center, bottom, etc.)

=head1 SYNOPSIS

    use Bivio::UI::Align;
    '<td '.Bivio::UI::Align->as_html('north').'>';

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::Align::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::Align> is a enum of alignment names to html alignment
values (via C<get_long_desc>).

The alignments and their values are:

=over 4

=item N (north, top): valign=top align=center

=item NE (northeast): valign=top align=right

=item E (east, right): align=right

=item SE (southeast): valign=bottom align=right

=item S (south, bottom): valign=bottom align=center

=item SW (southwest): valign=bottom align=left

=item W (west, left):

=item NW (northwest): valign=top align=left

=item CENTER: align=center

=item LEFT: align=left

=item RIGHT: align=right

=item TOP:  valign=top align=center

=item BOTTOM: valign=bottom align=center

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    'N' => [
	1,
	'north',
	' valign=top align=center',
    ],
    'NE' => [
	2,
	'northeast',
	' valign=top align=right',
    ],
    'E' => [
	3,
	'east',
	' align=right',
    ],
    'SE' => [
	4,
	'southeast',
	' valign=bottom align=right',
    ],
    'S' => [
	5,
	'south',
	' valign=bottom align=center',
    ],
    'SW' => [
	6,
	'southwest',
	' valign=bottom align=left',
    ],
    'W' => [
	7,
	'west',
	' align=left',
    ],
    'NW' => [
	8,
	'northwest',
	' valign=top align=left',
    ],
    CENTER => [
	9,
	undef,
	' align=center',
    ],
    LEFT => [
	10,
	undef,
	' align=left',
    ],
    RIGHT => [
	11,
	undef,
	' align=right',
    ],
    TOP => [
	12,
	undef,
	' valign=top align=center',
    ],
    BOTTOM => [
	13,
	undef,
	' valign=bottom align=center',
    ],
);

=head1 METHODS

=cut

=for html <a name="as_html_hex"></a>

=head2 as_html() : string

=head2 as_html(any thing) : string

Returns the alignment in html as C<VALIGN> and C<ALIGN> attributes
of C<TD> tag.  Prefixed with leading space.

=cut

sub as_html {
    return Bivio::Type::Enum::from_any(@_)->get_long_desc;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
