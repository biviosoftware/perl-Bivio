# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Enum;
use strict;
$Bivio::UI::HTML::Widget::Enum::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Enum - renders an enum as a string

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Enum;
    Bivio::UI::HTML::Widget::Enum->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::String>

=cut

use Bivio::UI::HTML::Widget::String;
@Bivio::UI::HTML::Widget::Enum::ISA = ('Bivio::UI::HTML::Widget::String');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Enum> renders an enum as a string. By default this
displays the result of 'get_short_desc'. This may be overridden by specifying
a enum value to widget mapping in the optional 'display_values' attribute.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the enum field to render.

=item display_values : hash_ref

Map of enum values to display values. Overrides enum->get_short_desc.
Values may be a string or Bivio::UI::HTML::Widget.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Enum

Creates a new Enum renderer.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::String::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes display_values and string attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{initialized};

    # convert any display values to string widgets if necessary
    my($display_values) = $self->unsafe_get('display_values');
    if (defined($display_values)) {
	foreach my $field (keys(%$display_values)) {
	    my($value) = $display_values->{$field};
	    $value = Bivio::UI::HTML::Widget::String->new({
		value => $value,
	    }) unless ref($value);
	    $value->put(parent => $self);
	    $value->initialize;
	    $display_values->{$field} = $value;
	}
    }

    # default is to display the short description
    $self->put(value => [$self->get('field'), '->get_short_desc']);

    $fields->{initialized} = 1;
    $self->SUPER::initialize;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the enum value onto the buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;

    # check for an overridden display value
    my($value) = $source->get_widget_value($self->get('field'));
    my($display_values) = $self->unsafe_get('display_values');

    if (defined($display_values) && exists($display_values->{$value})) {
	$display_values->{$value}->render($source, $buffer);
    }
    elsif (defined($value)) {
	$self->SUPER::render($source, $buffer);
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
