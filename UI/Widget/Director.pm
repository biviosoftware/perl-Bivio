# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Director;
use strict;
$Bivio::UI::Widget::Director::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Widget::Director - directs rendering to one widget of a set

=head1 SYNOPSIS

    use Bivio::UI::Widget::Director;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::Director::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::Director> is used to dynamically select among a set
of widgets.  A C<Director> is never constant but its I<values> might be.

=head1 ATTRIBUTES

=over 4

=item control : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>.
The result must match one of the keys in I<values>
or I<default_value> will be returned.  If I<default_value>
is not defined, is an error.

=item values : hash_ref (required)

The value selection of values.  The keys must match the type
of I<control>.  The values are widgets.
If a value is zero (0), renders nothing.

=item default_value : widget []

The widget to use when the I<control> does not match any of
the keys in I<values>.  If zero (0), renders nothing.

=item undef_value : widget []

The widget to use when the I<control> is undefined.
If zero (0), renders nothing.

=back

=cut

#=IMPORTS
use Bivio::Die;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::Widget::Director

=head2 static new(any control, hash_ref values, Bivio::UI::Widget default_value, Bivio::UI::Widget undef_value) : Bivio::UI::Widget::Director

Create a C<Director> widget with I<control>, I<values>,
I<default_value>, and I<undef_value>.  The last three of
which may be C<undef>.

Creates a new Director widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(_new_args(@_));
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_content_type"></a>

=head2 get_content_type(any source) : string

Gets the content type from the widget which would be rendered.

=cut

sub get_content_type {
    my($self, $source) = @_;
    my($w) = _select($self, $source);
    Bivio::Die->die('Director did not select a widget; no content type')
	    unless defined($w);
    return $w->get_content_type($source);
}

=for html <a name="initialize"></a>

=head2 initialize()

Copies the attributes to local fields.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{control});
    ($fields->{control}, $fields->{values})
	    = $self->get('control', 'values');
    $fields->{default_value} = $self->unsafe_get('default_value');
    $fields->{undef_value} = $self->unsafe_get('undef_value');
    my($child);
    foreach $child (values(%{$fields->{values}}), $fields->{default_value},
	    $fields->{undef_value}) {
	next unless $child;
	$child->put(parent => $self);
	$child->initialize;
    }
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the link.  Most of the code is involved in avoiding unnecessary method
calls.  If the I<value> is a constant, then it will only be rendered once.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($w) = _select($self, $source);
    $w->render($source, $buffer) if defined($w);
    return;
}

#=PRIVATE METHODS

# _new_args(proto, any value) : array
#
# Returns arguments to be passed to Attributes::new.
#
sub _new_args {
    my($proto, $value, $values, $default_value, $undef_value) = @_;
    return ($proto, $value) if ref($value) eq 'HASH' || int(@_) == 1;
    return ($proto, {
	control => $value,
	values => $values ? $values : {},
	default_value => $default_value,
	undef_value => $undef_value,
    }) if ref($value) eq 'ARRAY';
    Bivio::Die->die('invalid arguments to new');
    # DOES NOT RETURN
}

# _select(self, any source) : Bivio::UI::Widget
#
# Returns the widget to render or dies.
#
sub _select {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($ctl) = $source->get_widget_value(@{$fields->{control}});
    if (defined($ctl)) {
	my($values) = $fields->{values};
	return $values->{$ctl} || undef if defined($values->{$ctl});
	return $fields->{default_value} || undef
		if defined($fields->{default_value});
    }
    elsif (defined($fields->{undef_value})) {
	return $fields->{undef_value} || undef if $fields->{undef_value};
    }
    Bivio::Die->die($fields->{control}, ': invalid control value: ', $ctl);
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
