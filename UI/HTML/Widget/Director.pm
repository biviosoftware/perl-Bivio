# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Director;
use strict;
$Bivio::UI::HTML::Widget::Director::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Director - directs rendering to one widget of a set

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Director;
    Bivio::UI::HTML::Widget::Director->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Director::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Director> is used to dynamically select among a set
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

=item default_value : widget []

The widget to use when the I<control> does not match any of
the keys in I<values>.

=item undef_value : widget []

The widget to use when the I<control> is undefined.

=back

=cut

#=IMPORTS
use Bivio::IO::Alert;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Director

Creates a new Director widget.

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
	next unless defined($child);
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
    my($fields) = $self->{$_PACKAGE};
#TODO: Optimize for is_constant
    my($ctl) = $source->get_widget_value(@{$fields->{control}});
    if (defined($ctl)) {
	my($values) = $fields->{values};
	$values->{$ctl}->render($source, $buffer), return
		if $values->{$ctl};
	$fields->{default_value}->render($source, $buffer), return
		if $fields->{default_value};
    }
    elsif (defined($fields->{undef_value})) {
	$fields->{undef_value}->render($source, $buffer);
	return;
    }
    Bivio::IO::Alert->die($fields->{control},
	    ': invalid control value: ', $ctl);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
