# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Color;
use strict;
$Bivio::UI::Color::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Color - named colors

=head1 SYNOPSIS

    use Bivio::UI::Color;
    '<font Bivio::UI::Color->as_html('text_ia')>';
    '<td '.Bivio::UI::Color->as_html_bg('page_bg').'>';

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

If a color is negative, it is not displayed.

The current color names are:

=over 4

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    NO_COLOR_TAG => [
	-1,
    ],
    PAGE_BG => [
	0xFFFFFF,
	'image_menu_separator',
	'report_page_heading_bg',
        'celebrity_box_title',
        'celebrity_box_text_bg',
    ],
    ERROR => [
	0x990000,
	'warning',
    ],
    PAGE_TEXT => [
	0x000000,
	'table_separator',
    ],
    STRIPE_ABOVE_MENU => [
	0x009999,
	'celebrity_disclaimer',
	'tax_disclaimer',
    ],
    FOOTER_MENU => [
	0x006666,
	'page_vlink',
	'page_alink',
	'page_link',
	'user_name',
	'line_above_menu',
	'action_bar_border',
	'detail_chooser',
	'page_heading',
	'form_field_in_text',
	'text_menu_font',
        'celebrity_box',
	'description_label',
	'task_list_heading',
	'task_list_label',
    ],
    ICON_TEXT_IA => [
	0xEEEEEE,
    ],
    SUMMARY_LINE => [
	0x66CC66,
    ],
    TABLE_STRIPE_BG => [
	# This is not websafe, but it will round down to 0xCCCCCC
	# on systems that have only 256 colors.
	0xE4E4E4,
    ],
    REALM_NAME => [
	0xFF6633,
    ],
    TOP_MENU_BG => [
	0xffcc33,
	'action_bar_bg',
	'text_menu_line',
    ],
#    TEXT_MENU_FONT => [
#	0xCC9900,
#    ],
);

=head1 METHODS

=cut

=for html <a name="as_html"></a>

=head2 as_html(string attr) : string

=head2 as_html(string attr, any thing) : string

Returns the color as an attribute=value string suitable for HTML.

=cut

sub as_html {
    my($proto, $attr) = (shift, shift);
    my($c) = Bivio::Type::Enum::from_any($proto, @_)->as_int;
    return $c >= 0 ? sprintf(' %s="#%06X"', $attr, $c) : '';
}

=for html <a name="as_html_bg"></a>

=head2 as_html_bg() : string

=head2 as_html_bg(any thing) : string

Same as L<as_html|"as_html">, but generates C<BGCOLOR> attribute.

=cut

sub as_html_bg {
    shift->as_html('bgcolor', @_);
}

=head2 as_html_fg() : string

=head2 as_html_fg(any thing) : string

Returns the color as a C<COLOR> attribute.

=cut

sub as_html_fg {
    shift->as_html('color', @_);
}

=for html <a name="is_continuous"></a>

=head2 static is_continuous : false

Returns false.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
