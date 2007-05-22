# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Indirect;
use strict;
$Bivio::UI::Widget::Indirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::Indirect::VERSION;

=head1 NAME

Bivio::UI::Widget::Indirect - renders an arbitrary widget dynamically

=head1 RELEASE SCOPE

bOP

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
B<NOTE: the widget is not initialized.  You must do this yourself.>

=item value : array_ref (required,dynamic)

Accessed dynamically.  Widget value must be a widget or false.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::Widget::Indirect

=head2 static new(array_ref value) : Bivio::UI::Widget::Indirect

=head2 static new(Bivio::UI::Widget value) : Bivio::UI::Widget::Indirect

=head2 static new(boolean value) : Bivio::UI::Widget::Indirect

Creates a new Indirect widget.  I<value> may be anything but a hash_ref,
really.  If it is a hash_ref, it must contain a I<value> attribute.

=cut

sub new {
    my($proto, @args) = _new_args(@_);
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Executes the child widget as selected from I<req> (as source).

=cut

sub execute {
    my($self, $req) = @_;
    my($w) = _select($self, $req);
    Bivio::Die->die('Indirect did not select a widget; no content type')
	    unless defined($w);
    return $w->execute($req);
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
    return $v;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
