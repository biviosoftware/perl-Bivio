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

=item escape_text : boolean [1]

Determines whether the value will be passed to
L<Bivio::Util::escape_html|Bivio::Util/"escape_html"> before rendering.

=item string_font : string [] (inherited)

The value to be passed to L<Bivio::UI::Font|Bivio::UI::Font>.

=item pad_left : int [0]

Number of non-breaking spaces to pad on the left.

=item value : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item value : string (required)

Text to render.

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
    my($font) = $self->ancestral_get('string_font', undef);
    my($p, $s) = $font ? Bivio::UI::Font->as_html($font) : ('', '');
    my($pad_left) = $self->get_or_default('pad_left', 0);
    $p .= '&nbsp;' x $pad_left if $pad_left > 0;
    $fields->{value} = $self->get('value');
    if ($fields->{is_constant} = !ref($fields->{value})) {
    	$fields->{value} = $p.($self->get_or_default('escape_text', 1)
		? Bivio::Util::escape_html($fields->{value})
		: $fields->{value}).$s;
    }
    else {
	$fields->{prefix} = $p;
	$fields->{suffix} = $s;
    }
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will return true if always renders exactly the same way.

=cut

sub is_constant {
    return shift->{$_PACKAGE}->{is_constant};
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    die("String not initialized") unless exists($fields->{value});

    $$buffer .= $fields->{value}, return if $fields->{is_constant};
    my($value) = $source->get_widget_value(@{$fields->{value}});
    $$buffer .= $fields->{prefix}
	    .($self->get_or_default('escape_text', 1)
		    ? Bivio::Util::escape_html($value)
		    : $value)
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
