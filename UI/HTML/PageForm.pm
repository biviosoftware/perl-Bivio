# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::PageForm;
use strict;
$Bivio::UI::HTML::PageForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::PageForm - a form which can serve as page_content

=head1 SYNOPSIS

    use Bivio::UI::HTML::PageForm;
    Bivio::UI::HTML::PageForm->new($attr);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget::Form;
@Bivio::UI::HTML::PageForm::ISA = ('Bivio::UI::HTML::Widget::Form');

=head1 DESCRIPTION

C<Bivio::UI::HTML::PageForm> can serve as the I<page_content> for
a L<Bivio::UI::HTML::Page|Bivio::UI::HTML::Page>.  This means that
it has an L<execute|"execute"> method.

Subclasses must implement two methods:  L<create_fields|"create_fields">
and C<initialize>.  initialize must set the following attributes on
C<$self>:

=over 4

=item form_model

This is the widget value used by
L<Bivio::UI::HTML::Widget::Form|Bivio::UI::HTML::Widget::Form>
and its child fields.

=back

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::UI::HTML::General::Page;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::FormErrorList;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::StandardSubmit;
use Bivio::UI::HTML::Widget::Text;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::PageForm

Initializes the instance of itself.  Usually only called once
by L<Bivio::Agent::Task|Bivio::Agent::Task>.

Calls L<create_fields|"create_fields"> which must return a
I<values> array_ref suitable for a
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::Form::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{fields} = [];
    my($grid_values) = $self->create_fields;
    # Add the submit button
    push(@$grid_values, [
	Bivio::UI::HTML::Widget::StandardSubmit->new({
	    cell_expand => 1,
	    cell_align => 'center',
	}),
    ]);
    $self->put(
	    value => Bivio::UI::HTML::Widget::Join->new({
		values => [
		    Bivio::UI::HTML::Widget::FormErrorList->new({
			fields => $fields->{fields}
		    }),
		    Bivio::UI::HTML::Widget::Grid->new({
			pad => 5,
			values => $grid_values,
		    }),
		],
	    }),
	   );
    $self->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_field"></a>

=head2 add_field(string field, string label, int size) : array

=head2 add_field(string field, string label, Bivio::UI::HTML::Widget widget, string desc) : array

Adds a new field to the form.  A field has a I<label>.  If I<size> is
specified, aL<Bivio::UI::HTML::Widget::Text|Bivio::UI::HTML::Widget::Text>
with I<size> and I<field> will created.

If I<widget> is specified, it will be used.

Returns the
L<Bivio::UI::HTML::Widget::FormFieldLabel|Bivio::UI::HTML::Widget::FormFieldLabel> and field widget.

Adds fields to the array of fields return by L<get_fields|"get_fields">.

If <desc> exists, it will be added in a column to the right of the field.

=cut

sub add_field {
    my($self, $field, $label, $size_or_widget, $desc) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->map_field($field, $label);
    unless (ref($size_or_widget)) {
	$size_or_widget = Bivio::UI::HTML::Widget::Text->new({
	    field => $field,
	    size => $size_or_widget,
	});
    }
    return (Bivio::UI::HTML::Widget::FormFieldLabel->new({
	label => $label,
	field => $field,
	}),
	$size_or_widget,
    );
#TODO: Descriptions need a layout design.
#    return @basic unless $desc;
#    return (
#Bivio::UI::HTML::Widget::Grid->new({
#	cell_align => 'nw',
#	pad => 5,
#	values => [
#	Bivio::UI::HTML::Widget::Join->new({
#	    cell_align => 'nw',
#	    values => [
#		$basic[0],
#		"<br>",
#		$basic[1],
#	    ],
#	}),
#        Bivio::UI::HTML::Widget::Join->new({values => [$desc]}),
#    );
}

=for html <a name="create_caption"></a>

=head2 create_caption(string caption, Widget widget) : (FormFieldLabel, Widget)

Creates a FormFieldLabel for the specified widget and returns both.
Adds fields to the array of fields return by L<get_fields|"get_fields">.

=cut

sub create_caption {
    my($self, $caption, $widget) = @_;

    return $self->add_field($widget->get('field'), $caption, $widget);
}

=for html <a name="create_fields"></a>

=head2 abstract create_fields() : array_ref

Returns an array_ref suitable to be assigned to I<values> attribute
of L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=cut

sub create_fields {
    die('abstract method');
}

=for html <a name="get_fields"></a>

=head2 get_fields() : array_ref

Returns the array_ref containing the fields.  It is passed by reference.

=cut

sub get_fields {
    return shift->{$_PACKAGE}->{fields};
}

=for html <a name="map_field"></a>

=head2 map_field(string field, string label)

Maps a field to a label for error messages.  Insert in order.

=cut

sub map_field {
    my($self, $field, $label) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{fields}}, [$field, $label]);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
