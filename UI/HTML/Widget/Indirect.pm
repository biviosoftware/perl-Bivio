# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Indirect;
use strict;
$Bivio::UI::HTML::Widget::Indirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Indirect - renders an arbitrary widget dynamically

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Indirect;
    Bivio::UI::HTML::Widget::Indirect->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Indirect::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Indirect> adds a level of indirection to
the rendering of widgets.  The widget which is this widget's I<value>
is rendered dynamically by accessing this widget's attributes dynamically.

=head1 ATTRIBUTES

=over 4

=item value : Bivio::UI::HTML::Widget (required,dynamic)

Accessed dynamically.  If the dynamic value is false, nothing is rendered.

=item value : array_ref (required,dynamic)

Accessed dynamically.  Widget value must be a widget or
false.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

No op.

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
    my($v) = $self->get('value');
    return unless ref($v);
    $v = $source->get_widget_value($v) if ref($v) eq 'ARRAY';
    $v->render($source, $buffer) if ref($v);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
