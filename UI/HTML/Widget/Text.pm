# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Text;
use strict;
$Bivio::UI::HTML::Widget::Text::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Text - text and password form input fields

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Text;
    Bivio::UI::HTML::Widget::Text->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Text::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Text> draws a C<INPUT> tag with
attribute C<TYPE=TEXT>.  If I<field> I<isa>
L<Bivio::Type::Password|Bivio::Type::Password>,
will render as a C<TYPE=PASSWORD>.

=head1 ATTRIBUTES

=over 4

=item event_handler : Bivio::UI::HTML::Widget []

If set, this widget will be initialized as a child and must
support a method C<get_html_field_attributes> which returns a
string to be inserted in this fields declaration.
I<event_handler> will be rendered before this field.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item format : string []

=item format : array_ref []

Widget value which returns the formatter to format the field
if it is not in error.  May return C<undef> iwc no formatting
will done.

Only in the first case will the formatter be dymically loaded.
This is to prevent unnecessary transient state.

The second form may be deprecated, so try to avoid it.

=item size : int (required)

How wide is the field represented.  (maxlength comes from the
field's type.)

=back

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::UI::HTML::Format;
use Bivio::Type::Password;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(@_ATTRS) = qw(
    event_handler
    field
    form_model
    format
    size
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Text

Creates a new Text widget.

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

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{size}) = $self->get('field', 'size');

    # Initialize handler, if any
    $fields->{handler} = $self->unsafe_get('event_handler');
    if ($fields->{handler}) {
	$fields->{handler}->put(parent => $self);
	$fields->{handler}->initialize;
    }

    $fields->{format} = $self->unsafe_get('format');
    $fields->{format}
	    = Bivio::UI::HTML::Format->get_instance($fields->{format})
		    if defined($fields->{format}) && !ref($fields->{format});
    return;
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.  First render is special, because we need
to extract the field's type and can only do that when we have a form.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<input type='
		.($type->isa('Bivio::Type::Password') ? 'password' : 'text')
		.' size='.$fields->{size}.' maxlength='.$type->get_width();
	$fields->{prefix} .= $fields->{handler}->get_html_field_attributes(
		$field, $source) if $fields->{handler};
	$fields->{prefix} .= ' name=';
	$fields->{initialized} = 1;
    }

    # Name
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    $$buffer .= $p.$fields->{prefix}.$form->get_field_name_for_html($field);

    # Format if provided
    my($v);
    if ($fields->{format} && !$form->get_field_error($field)) {
	my($f) = ref($fields->{format}) eq 'ARRAY'
		? $source->get_widget_value(@{$fields->{format}})
		: $fields->{format};
	if ($f) {
	    $v = $f->get_widget_value($form->get($field));
	    # Formatter must always return a defined value
	    $v = Bivio::Util::escape_html($v) unless $f->result_is_html;
	}
    }
    $v = $form->get_field_as_html($field) unless defined($v);

    # Value
    $$buffer .= ' value="'.$v.'">'.$s;

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
