# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Font;
use strict;
$Bivio::UI::Font::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Font - named fonts

=head1 SYNOPSIS

    use Bivio::UI::Font;
    join('my heading', Bivio::UI::Font->as_html('page_heading'));

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::Font::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::Font> is a map of font names to html values.

The current font names are:

=over 4

=item PAGE_HEADING

=item TABLE_HEADING

=item TABLE_CELL

=item ICON_TEXT_IA

=item ERROR

=item ITALIC

=item TIME

=back

=cut

#=IMPORTS
use Bivio::UI::Color;

#=VARIABLES
# Format:
#   name => [face, color, size/style(s)]
my($_SANS_SERIF) = 'arial,helvetica,sans-serif';
_compile([
    PAGE_HEADING => [$_SANS_SERIF, undef, 'large', 'strong'],
    TABLE_HEADING => [$_SANS_SERIF],
    TABLE_CELL => [undef, undef, 'small'],
    ICON_TEXT_IA => [undef, 'icon_text_ia'],
    ERROR => [undef, 'error', 'i'],
    ITALIC => [undef, undef, 'i'],
    TIME => [$_SANS_SERIF, undef, 'small'],
]);

=head1 METHODS

=cut

=for html <a name="as_html"></a>

=head2 as_html() : array

=head2 as_html(any thing) : array

Returns the font as prefix and suffix strings to surround the text with.

=cut

sub as_html {
    return split(/$;/, Bivio::Type::Enum::from_any(@_)->get_long_desc);
}

#=PRIVATE METHODS

# _compile(array_ref map) 
#
# Custom implementation of compile to keep above map simple.
#
sub _compile {
    my($map) = @_;
    my($m);
    my($n) = 1;
    foreach $m (@$map) {
	next unless ref($m);
	my($face, $color, @styles) = @$m;
	$#$m = -1;
	my($size);
	my($p, $s) = ('', '');
	while (@styles) {
	    my($style) = shift(@styles);
	    $size = $style, next if $style =~ /^[-+]?\d+$/;
	    $p .= "<$style>";
	    $s = "</$style>" . $s;
	}
	if ($color || $face || defined($size)) {
	    $p .= '<font';
	    $p .= ' face="'.$face.'"' if $face;
	    $p .= Bivio::UI::Color->as_html($color) if $color;
	    $p .= ' size="'.$size.'"' if defined($size);
	    $p .= '>';
	    $s = '</font>' . $s;
	}
	push(@$m, $n++, undef, $p.$;.$s);
    }
    __PACKAGE__->compile(@$map);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
