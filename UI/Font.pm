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

=item LIST_ERROR

=item ITALIC

=item TIME

=item NUMBER_CELL

=item TABLE_ROW_TITLE

=item FORM_FIELD_LABEL

=item FORM_FIELD_ERROR_LABEL

=item REALM_NAME

=item FORM_SUBMIT

=item SUBSTITUTE_USER

=back

=cut

#=IMPORTS
use Bivio::UI::Color;

#=VARIABLES
# Format:
#   name => [face, color, size/style(s)]
my($_SANS_SERIF) = 'verdana,arial,sans-serif';
_compile([
    PAGE_HEADING => [$_SANS_SERIF, 'page_heading', 'strong'],
    TASK_LIST_HEADING => [undef, 'task_list_heading', 'strong'],
    TABLE_HEADING => [$_SANS_SERIF, undef, 'strong'],
    NORMAL_TABLE_HEADING => [$_SANS_SERIF, undef, 'strong'],
    TABLE_CELL => [undef, undef],
    ICON_TEXT_IA => [undef, 'icon_text_ia'],
    ERROR => [undef, 'error', 'b'],
    WARNING => [undef, 'warning', 'b'],
    LIST_ERROR => [undef, 'error', 'small'],
    CHECKBOX_ERROR => [undef, 'error', 'small'],
    ITALIC => [undef, undef, 'i'],
    TIME => [$_SANS_SERIF, undef, 'small'],
    NUMBER_CELL => [undef, undef],
    TABLE_ROW_TITLE => [undef, undef, 'strong'],
    FORM_FIELD_LABEL => [undef, undef],
    FORM_FIELD_IN_TEXT => [undef, 'form_field_in_text', 'strong'],
    DESCRIPTION_LABEL => [undef, 'description_label', 'strong'],
    TASK_LIST_LABEL => [undef, 'task_list_label'],
    FORM_FIELD_ERROR_LABEL => [undef, 'error', 'i'],
    REALM_NAME => [$_SANS_SERIF, 'realm_name', 'strong'],
    USER_NAME => [$_SANS_SERIF, 'user_name', 'big'],
    FORM_SUBMIT => [$_SANS_SERIF, undef],
    SUBSTITUTE_USER => [$_SANS_SERIF, 'error', 'big', 'strong'],
    FOOTER_MENU => [$_SANS_SERIF, 'footer_menu', 'small'],
    ACTION_BAR_STRING => [undef, undef, 'strong'],
    ACTION_BUTTON => [undef, undef],
    REPORT_PAGE_HEADING => [$_SANS_SERIF, undef, 'big', 'strong'],
    TEXT_MENU_NORMAL => [$_SANS_SERIF, 'text_menu_font',],
    TEXT_MENU_SELECTED => [$_SANS_SERIF, 'text_menu_font', 'strong'],
    DETAIL_CHOOSER => [$_SANS_SERIF, 'detail_chooser', 'strong'],
    MESSAGE_SUBJECT => [$_SANS_SERIF, undef],
    LIST_ACTION => [undef, undef, 'small'],
    STRONG => [undef, undef, 'strong'],
    RADIO => [undef, undef],
    CELEBRITY_BOX_TITLE => [$_SANS_SERIF, 'celebrity_box_title'],
    CELEBRITY_BOX_TEXT => [$_SANS_SERIF, undef, 'small'],
    FILE_TREE_BYTES => [undef, undef, 'small'],
    LABEL_IN_TEXT => [undef, undef, 'b'],
]);

=head1 METHODS

=cut

=for html <a name="as_html"></a>

=head2 as_html() : array

=head2 as_html(any thing) : array

Returns the font as prefix and suffix strings to surround the text with.

=cut

sub as_html {
    # 2 forces exactly two fields (even if both are zero length)
    return split(/$;/, Bivio::Type::Enum::from_any(@_)->get_long_desc, 2);
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
	    $p .= Bivio::UI::Color->as_html_fg($color) if $color;
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
