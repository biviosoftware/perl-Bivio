# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Color;
use strict;
$Bivio::UI::Color::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Color - named colors

=head1 SYNOPSIS

    use Bivio::UI::Color;
    Bivio::UI::Color->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::Color::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::Color> is a map of names to rgb color values.  The
color values are represented integers.  Therefore, no two colors
are alike.  However, there can be three aliases (name, short
description, and long description) for each color.

=cut

=head1 CONSTANTS

=cut

=for html <a name="IS_CONTINUOUS"></a>

=head2 IS_CONTINUOUS : false

Returns false.

=cut

sub IS_CONTINUOUS {
    return 0;
}

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    PAGE_BG => [
	0xFFFFFF,
    ],
    HEADING_BG => [
	0xE0E0FF,
	'text_tab_bg',
    ],
    TABLE_STRIPE_BG => [
	0xEEEEEE,
	'icon_text_ia',
    ],
    ERROR => [
	0xFF0000,
    ],
);

=head1 METHODS

=cut

=for html <a name="as_html"></a>

=head2 as_html() : string

=head2 as_html(any thing) : string

Returns the color as a C<COLOR> attribute.

=cut

sub as_html {
    return sprintf(' color="#%06X"', Bivio::Type::Enum::from_any(@_)->as_int);
}

=for html <a name="as_html_bg"></a>

=head2 as_html_bg() : string

=head2 as_html_bg(any thing) : string

Same as L<as_html|"as_html">, but generates C<BGCOLOR> attribute.

=cut

sub as_html_bg {
    return sprintf(' bgcolor="#%06X"',
	    Bivio::Type::Enum::from_any(@_)->as_int);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
