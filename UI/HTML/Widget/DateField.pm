# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateField;
use strict;
$Bivio::UI::HTML::Widget::DateField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::DateField - a date field for forms

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::DateField;
    Bivio::UI::HTML::Widget::DateField->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::DateField::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::DateField> is a date field for forms.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Format::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::DateField

Creates a Date widget.

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

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the date field on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	my($width) = $type->get_width();
	$fields->{prefix} = '<input name='
		.$form->get_field_name_for_html($field)
		." type=text size=$width maxlength=$width";
	$fields->{initialized} = 1;
    }
    $$buffer .= $fields->{prefix};
    my($value) = $form->get($field) || '';

    # need to change dates from 'J SSSSS' format to display format
    if ($value =~ /\s/) {
	$value = Bivio::UI::HTML::Format::Date->get_widget_value($value)
    }

    $$buffer .= ' value="'.$value.'">';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
