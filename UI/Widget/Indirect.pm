# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Indirect;
use strict;
$Bivio::UI::Widget::Indirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Widget::Indirect - renders an arbitrary widget dynamically

=head1 SYNOPSIS

    use Bivio::UI::Widget::Indirect;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::Indirect::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::Indirect> adds a level of indirection to
the rendering of widgets.  The widget which is this widget's I<value>
is rendered dynamically by accessing this widget's attributes dynamically.

=head1 ATTRIBUTES

=over 4

=item value : Bivio::UI::Widget (required, dynamic)

Accessed dynamically.  If the dynamic value is false, nothing is rendered.

=item value : array_ref (required,dynamic)

Accessed dynamically.  Widget value must be a widget or false.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::Widget::Indirect

=head2 static new(array_ref value) : Bivio::UI::Widget::Indirect

=head2 static new(Bivio::UI::Widget value) : Bivio::UI::Widget::Indirect

=head2 static new(boolean value) : Bivio::UI::Widget::Indirect

Creates a new Indirect widget.  I<value> may be anything but a hash_ref,
really.  If ti is a hash_ref, it must contain a I<value> attribute.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(_new_args(@_));
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=for html <a name="get_content_type"></a>

=head2 get_content_type(any source) : string

Gets the content type from the widget which would be rendered.

=cut

sub get_content_type {
    my($self, $source) = @_;
    my($w) = _select($self, $source);
    Bivio::Die->die('Indirect did not select a widget; no content type')
	    unless defined($w);
    return $w->get_content_type($source);
}

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Does nothing.  The widget is fully dynamic.

=cut

sub initialize {
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the indirect.  If there the widget value is false, then
nothing is rendered.  If the widget value is an array_ref,
it first calls get_widget_value to get the actual value.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($w) = _select($self, $source);
    $w->render($source, $buffer) if ref($w);
    return;
}

#=PRIVATE METHODS

# _new_args(proto, any value, ...) : array
#
# Returns arguments to be passed to Attributes::new.
#
sub _new_args {
    my($proto, $value) = @_;
    return ($proto, $value) if ref($value) eq 'HASH';
    # We accept any value
    return ($proto, {
	value => $value,
    });
    # DOES NOT RETURN
}

# _select(self, any source) : Bivio::UI::Widget
#
# Returns the widget as directed by the source
#
sub _select {
    my($self, $source) = @_;
    my($v) = $self->get('value');
    return unless ref($v);
    return $source->get_widget_value(@$v) if ref($v) eq 'ARRAY';
    Bivio::Die->die($self->get('value'), ': bad indirect widget');
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
