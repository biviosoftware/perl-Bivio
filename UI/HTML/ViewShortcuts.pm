# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ViewShortcuts;
use strict;
$Bivio::UI::HTML::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::ViewShortcuts::VERSION;

=head1 NAME

Bivio::UI::HTML::ViewShortcuts - html helper routines

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::ViewShortcuts

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcuts>

=cut

use Bivio::UI::ViewShortcuts;
@Bivio::UI::HTML::ViewShortcuts::ISA = qw(Bivio::UI::ViewShortcuts);

=head1 DESCRIPTION

Provides many utility routines to help create widgets and such.

Some of these routines are deprecated.

=cut


=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::IO::ClassLoader;
#NOTE: Do not import any widgets here, use _use().

#=VARIABLES

=head1 METHODS

=for html <a name="vs_blank_cell"></a>

=head2 static vs_blank_cell() : Bivio::UI::Widget

Returns a cell which renders a blank.  Makes the code clearer to use.

=cut

sub vs_blank_cell {
    return shift->vs_join('&nbsp;');
}

=for html <a name="vs_center"></a>

=head2 static vs_center(any value, ....) : Bivio::UI::Widget

Create a centered DIV from the contents.

=cut

sub vs_center {
    return shift->vs_join(["\n<div align=center>\n", @_, "\n</div>\n"]);
}

=for html <a name="vs_clear_dot"></a>

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_clear_dot {
    my($proto, $width, $height) = @_;
    return $proto->vs_new('ClearDot', {
	defined($width) ? (width => $width) : (),
	defined($height) ? (height => $height) : (),
    });
}

=for html <a name="vs_clear_dot_as_html"></a>

=head2 clear_dot_as_html(int width, int height) : string

Returns an html string which loads a ClearDot image in
width and height.

Don't use in rendering code.  Use L<vs_clear_dot|"vs_clear_dot"> instead.

=cut

sub vs_clear_dot_as_html {
    my(undef) = shift;
    my($c) = _use('ClearDot');
    return $c->as_html(@_);
}

=for html <a name="vs_director"></a>

=head2 static vs_director(any control, hash_ref values, Bivio::UI::Widget default_value, Bivio::UI::Widget undef_value) : Bivio::UI::Widget

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_director {
    my($proto) = shift;
    return $proto->vs_new('Director', @_);
}

=for html <a name="vs_image"></a>

=head2 static vs_image(any icon) : Bivio::UI::HTML::Widget::Image

=head2 static vs_image(any icon, any alt, hash_ref attrs) : Bivio::UI::HTML::Widget::Image

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_image {
    my($proto, $icon, $alt, $attrs) = @_;
    _use('Image');
    return Bivio::UI::HTML::Widget::Image->new({
	src => $icon,
	(defined($alt) || ref($icon) ? (alt => $alt) : (alt_text => $icon)),
	$attrs ? %$attrs : (),
    });
}

=for html <a name="vs_join"></a>

=head2 static vs_join(any value, ...) : Bivio::UI::Widget::Join

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_join {
    my($proto, @values) = @_;
    my($values) = int(@values) == 1 && ref($values[0]) eq 'ARRAY'
	    ? $values[0] : [@values];
    return $proto->vs_new('Join', $values);
}

=for html <a name="vs_link"></a>

=head2 static vs_link(string task) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, string task) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, string task, string font) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, array_ref widget_value) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, Bivio::UI::Widget widget) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, string abs_uri) : Bivio::UI::HTML::Widget::Link

If only I<task> is supplied, it is used for both the label and the href.
It will also be the control for the link.  This is the preferred way
to create links.

Returns a C<Link> with I<label> and I<widget_value>

If I<label> is not a widget, will wrap in a C<String> widget.

If I<task> is passed, will create a widget value by formatting
as a stateless uri for the TaskId named by I<task>.

If I<abs_uri> is passed, it must contain a / or : or #.

=cut

sub vs_link {
    my($proto, $label, $widget_value, $font) = @_;
    _use('Link');
    my($control);
    if (int(@_) <= 2) {
	$control = $label;
	$widget_value = $label;
	$label = $proto->vs_text($widget_value);
    }
    unless (UNIVERSAL::isa($label, 'Bivio::UI::Widget')) {
	$label = $proto->vs_string($label);
    }
    else {
#TODO: Does this make sense. I put it it in for backward compatibility [RJN]
	# Don't assign the font unless creating a string.
	$font = undef;
    }
    $widget_value = [['->get_request'], '->format_stateless_uri',
	Bivio::Agent::TaskId->$widget_value()]
	    # Use widget value or abs_uri (literal)
	    unless ref($widget_value) || $widget_value =~ m![/:#]!;
    return Bivio::UI::HTML::Widget::Link->new({
	href => $widget_value,
	value => $label,
	$control ? (control => $control) : (),
	defined($font) ? (string_font => $font) : (),
    });
}

=for html <a name="vs_link_target_as_html"></a>

=head2 static vs_link_target_as_html(Bivio::UI::Widget widget) : string

Looks up the attribute I<link_target> ancestrally and renders
it as ' target="XXX"' (with leading space) whatever its value is.

Default is '_top', because we don't use frames.

=cut

sub vs_link_target_as_html {
    my($proto, $widget) = @_;
    my($t) = $widget->ancestral_get('link_target', '_top');
    return defined($t) ? (' target="'.Bivio::HTML->escape($t).'"') : '';
}

=for html <a name="vs_new"></a>

=head2 static vs_new(string class, any new_args, ...) : Bivio::UI::Widget

Returns an instance of I<class> created with I<new_args>.  Loads I<class>, if
not already loaded.

=cut

sub vs_new {
    my(undef, $class) = (shift, shift);
    my($c) = _use($class);
    return $c->new(@_);
}

=for html <a name="vs_string"></a>

=head2 static vs_string(any value) : Bivio::UI::Widget::String

=head2 static vs_string(any value, string font) : Bivio::UI::Widget::String

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_string {
    my($proto, $value, $font) = @_;
    return $proto->vs_new('String', $value, $font);
}

#=PRIVATE METHODS

# _use(string class, ....) : array
#
# Executes Bivio::IO::ClassLoader->simple_require on its args.  Inserts
# HTMLWidget# prefix, if class does not contain
# colons.  Returns the named classes.
#
sub _use {
    my(@class) = @_;
    return map {
	$_ =~ /:/ ? Bivio::IO::ClassLoader->simple_require($_)
	: Bivio::IO::ClassLoader->map_require('HTMLWidget', $_);
    } @class;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
