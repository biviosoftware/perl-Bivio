# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::String;
use strict;
$Bivio::UI::HTML::Widget::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::String - renders a string with font decoration

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::String;
    Bivio::UI::HTML::Widget::String->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::String::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::String> draws a string with decoration.  Does no
alignment (see L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>
for layout issues).

=head1 ATTRIBUTES

=over 4

=item string_font : string []

The value to be passed to L<Bivio::UI::Font|Bivio::UI::Font>.

=item value : array_ref (required,simple)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item value : string (required,simple)

Text to render.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

=back

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::UI::Font;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::String

Creates a new String widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    my($font) = $self->unsafe_get('string_font');
    my($p, $s) = $font ? Bivio::UI::Font->as_html($font) : ('', '');
    $fields->{value} = $self->simple_get('value');
    if (ref($fields->{value})) {
	$fields->{prefix} = $p;
	$fields->{suffix} = $s;
    }
    else {
	$fields->{value} = $p.Bivio::Util::escape_html($fields->{value}).$s;
    }
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will return true if always renders exactly the same way.

=cut

sub is_constant {
    return ref(shift->{$_PACKAGE}->{value});
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($v) = $fields->{value};
    $$buffer .= $v, return unless ref($v);
    $$buffer .= $fields->{prefix}
	    .Bivio::Util::escape_html($source->get_widget_value(@$v))
	    .$fields->{suffix};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
