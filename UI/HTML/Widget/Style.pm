# Copyright (c) 2000-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Style;
use strict;
$Bivio::UI::HTML::Widget::Style::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Style - generates an inline style sheet

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Style;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Style::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Style> generates an inline style sheet.
Appropriate for use with
L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>
I<style> attribute.

=head1 ATTRIBUTES

=over 4

=item other_styles : array_ref ['']

Returns a string for styles.

=back

=head1 FACADE ATTRIBUTES

=over 4

=item Bivio::UI::Font.default : hash_ref (required)

The default font information.

=item Bivio::UI::Color.page_link_hover : string (required)

If non-empty, will render a style for C<a:hover>.

=back

=head1 REQUEST ATTRIBUTES

=over 4

=item font_with_style : boolean (set)

If rendering an inline style sheet, will set this attribute to true
on the request.

=item Bivio::Type::UserAgent : Bivio::Type::UserAgent (required)

If the agent supports css, will render a full style sheet.
Otherwise will render a partial style sheet.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_NO_HTML_KEY) = __PACKAGE__ . 'no_html';
my($_TAGS) = join(',', qw(
    address
    blockquote
    body
    button
    center
    div
    dl
    input
    ins
    kbd
    label
    legend
    menu
    multicol
    ol
    p
    pre
    select
    th
    td
    textarea
    ul
));

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Renders the table.

Calls
L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
as text/css

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req->put(
        font_with_style => 1,
        $_NO_HTML_KEY => 1,
    ), 'text/css');
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

Renders the appropriate style sheet.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;

    # Only real browsers get style sheets, sorry.
    return unless $req->unsafe_get('font_with_style');

    # Begin
    $$buffer .= "<style>\n<!--\n"
        unless $req->unsafe_get($_NO_HTML_KEY);

    # Font
    my($font) = Bivio::UI::Font->get_attrs('default', $req);
    if ($font) {
	$$buffer .= $_TAGS . " {\n";
	# If the value isn't set or is zero, then don't render.
	$$buffer .= ' font-family : '.$font->{family}.';' if $font->{family};
	$$buffer .= ' font-size : '.$font->{size}.';'
		if $font->{size};
	$$buffer .= " }\n";
    }

    # Hover (overrides font)
    my($hover) = Bivio::UI::Color->format_html('page_link_hover', 'color:',
	    $req);
    $$buffer .= 'a:hover { '.$hover." }\n" if $hover;
    $self->unsafe_render_attr('other_styles', $source, $buffer);

    # End
    $$buffer .= "\n-->\n</style>\n"
        unless $req->unsafe_get($_NO_HTML_KEY);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
