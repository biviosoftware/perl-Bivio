# Copyright (c) 2001 bivio Software Artisans Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormField;
use strict;
$Bivio::UI::HTML::Widget::FormField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::FormField::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::FormField - form model field renderer

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormField;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::Join>

=cut

use Bivio::UI::Widget::Join;
@Bivio::UI::HTML::Widget::FormField::ISA = ('Bivio::UI::Widget::Join');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormField>

=head1 ATTRIBUTES

=over 4

=item edit_attributes : hash_ref

Attributes for the editable field widget.

=item field : string (required)

Full name of the form field. ex. 'LoginForm.RealmOwner.name'

=item row_control : array_ref

Widget value boolean which dynamically determines if the row should render.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;
use Bivio::UI::HTML::WidgetFactory;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::FormField

=head2 static new(string field) : Bivio::UI::HTML::Widget::FormField

=head2 static new(string field, hash_ref edit_attributes) : Bivio::UI::HTML::Widget::FormField

=head2 static new(string field, hash_ref edit_attributes, array_ref row_control) : Bivio::UI::HTML::Widget::FormField

Creates a new FormField widget. Call
L<get_label_and_field|"get_label_and_field"> to create a label for the
field automatically.

=cut

sub new {
    my($self) = Bivio::UI::Widget::Join::new(@_);
    $self->[$_IDI] = {};

    # adds the error widget and the edit widget
    $self->put(values => [
	$_VS->vs_new('FormFieldError', {
	    field => _get_field_name($self),
	    label => _get_label_value($self),
	}),
	Bivio::UI::HTML::WidgetFactory->create($self->get('field'),
		$self->get_or_default('edit_attributes', {}))
    ]);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_label_and_field"></a>

=head2 get_label_and_field() : (Bivio::UI::HTML::Widget::FormFieldLabel, Bivio::UI::HTML::Widget::FormField)

Creates a label for the field, and returns the (label, field) pair.

=cut

sub get_label_and_field {
    my($self) = @_;

    return ($_VS->vs_new('FormFieldLabel', {
	field => _get_field_name($self),
	label => $_VS->vs_string(
	    $_VS->vs_join(
		$_VS->vs_string(_get_label_value($self), 0),
		':'),
	    'form_field_label'),
	($self->unsafe_get('row_control')
	    ? (row_control => $self->get('row_control'))
	    : ()),
    }), $self);
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(string field) : hash_ref

=head2 static internal_new_args(string field, hash_ref edit_attributes) : hash_ref

=head2 static internal_new_args(string field, hash_ref edit_attributes, array_ref row_control) : hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my($proto, $field, $edit_attributes, $row_control) = @_;

    return {
	field => $field,
	($edit_attributes ? (edit_attributes => $edit_attributes) : ()),
	($row_control ? (row_control => $row_control) : ()),
    };
}

#=PRIVATE METHODS

# _get_field_name(self) : string
#
# Returns the shortened field name for a form field (doesn't include
# the form model prefix).
#
sub _get_field_name {
    my($self) = @_;

    my($field_name) = $self->get('field');
    # remove the form model prefix
    $field_name =~ s/^.*?\.(.+)$/$1/;
    return $field_name;
}

# _get_label_value(self) : array_ref
#
# Returns the widget value which access the label.
#
sub _get_label_value {
    my($self) = @_;

    my($label_name) = $self->get('field');
    # strip out any suffix, not used for label lookup
    $label_name =~ s/_\d+(\.\w+)$/$1/;
    return [['->get_request'], 'Bivio::UI::Facade', 'Text',
	'->get_value', $label_name];
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
