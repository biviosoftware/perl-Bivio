# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Style;
use strict;
$Bivio::UI::HTML::Widget::Style::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Style - generates an inline style sheet

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

If the type is C<BROWSER> (read MSIE), will render a full style sheet.
If C<BROWSER_HTML3> (read Netscape), will render a partial style sheet.

=back

=cut

#=IMPORTS

#=VARIABLES

my($_PACKAGE) = __PACKAGE__;
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
    td
    textarea
    ul
));

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::Style

Returns a new instance.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Does nothing.

=cut

sub initialize {
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

Renders the appropriate style sheet.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;

    # Only real browsers get style sheets, sorry.
    return unless $req->get('Bivio::Type::UserAgent')
	    == Bivio::Type::UserAgent::BROWSER();

    $req->put(font_with_style => 1);

    # Begin
    $$buffer .= "<style>\n<!--\n";

    # Font
    my($font) = Bivio::UI::Font->get_attrs('default', $req);
    if ($font) {
	$$buffer .= $_TAGS." {\n";
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

    # End
    $$buffer .= "-->\n</style>\n";
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
