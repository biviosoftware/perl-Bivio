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

B<Don't use this for DateTime values.>

=head1 ATTRIBUTES

=over 4

=item allow_undef : boolean [false]

Allow undef for field, i.e. don't fill in with now.

=item event_handler : Bivio::UI::HTML::Widget []

If set, this widget will be initialized as a child and must
support a method C<get_html_field_attributes> which returns a
string to be inserted in this fields declaration.
I<event_handler> will be rendered before this field.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=back

=cut

#=IMPORTS
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::UI::DateTimeMode;
use Bivio::UI::HTML::Format::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_MODE_INT) = Bivio::UI::DateTimeMode->DATE->as_int;
my(@_ATTRS) = qw(
    allow_undef
    event_handler
    field
    form_model
);

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

=for html <a name="accepts_attribute"></a>

=head2 static accepts_attribute(string attr) : boolean

Does the widget accept this attribute?

=cut

sub accepts_attribute {
    my(undef, $attr) = @_;
    return grep($_ eq $attr, @_ATTRS);
}

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
    $fields->{allow_undef} = $self->get_or_default('allow_undef', 0);

    # Initialize handler, if any
    $fields->{handler} = $self->unsafe_get('event_handler');
    if ($fields->{handler}) {
	$fields->{handler}->put(parent => $self);
	$fields->{handler}->initialize;
    }
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

#TODO: Merge with Text.  Too much duplicated code.
    # first render initialization
    unless ($fields->{initialized}) {
	my($type) = $form->get_field_type($field);
	# Might be a subclass of Bivio::Type::Date
	my($width) = $type->get_width();
	$fields->{prefix} = "<input type=text size=$width maxlength=$width";
	$fields->{prefix} .= $fields->{handler}->get_html_field_attributes(
		$field) if $fields->{handler};
	$fields->{prefix} .= ' name=';
	$fields->{suffix} = '">';
	$fields->{initialized} = 1;
    }

    # If field in error, just return the value user entered
    $$buffer .= $fields->{prefix}.$form->get_field_name_for_html($field)
	    .' value="';
 SWITCH:
    {
	if ($form->get_field_error($field)) {
	    $$buffer .= $form->get_field_as_html($field).$fields->{suffix};
	    last SWITCH;
	}

	# Default is local_today unless allow_undef set
	my($value) = $form->get($field);
	unless (defined($value)) {
	    if ($fields->{allow_undef}) {
		$$buffer .= $fields->{suffix};
		last SWITCH;
	    }
	    $value = Bivio::Type::Date->local_today;
	}

	# We render the date in GMT always.  The only strange case
	# is when we render the default.  Otherwise, values are
	# coming from the db which means they are GMT anyway and
	# have a fixed time component.
	$$buffer .= Bivio::Type::Date->to_literal($value).$fields->{suffix};
    }

    # Handler is rendered after, because it probably needs to reference the
    # field.
    $fields->{handler}->render($source, $buffer) if $fields->{handler};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
