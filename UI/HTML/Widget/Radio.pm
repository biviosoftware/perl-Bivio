# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Radio;
use strict;
$Bivio::UI::HTML::Widget::Radio::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Radio::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Radio - a radio input field

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Radio;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::ControlBase>

=cut

use Bivio::UI::Widget::ControlBase;
@Bivio::UI::HTML::Widget::Radio::ISA = ('Bivio::UI::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Radio> is an input of type C<RADIO>.
It always has a label, but the label may be a string or widget.

=head1 ATTRIBUTES

=over 4

=item auto_submit : boolean [0]

Should the a click submit the form?

=item control : any

See L<Bivio::UI::Widget::ControlBase|Bivio::UI::Widget::ControlBase>.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item label : string (required)

=item label : array_ref (required)

=item label : Bivio::UI::Widget (required)

String label to use.

=item value : any (required)

Scalar value of button or Bivio::Type::Enum.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::UI::Font;

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string field, any value, any label, hash_ref attrs) : Bivio::UI::HTML::Widget::Radio

I<value> may be a scalar, L<Bivio::Type::Enum|Bivio::Type::Enum>, or
array_ref which returns one of these.

I<label> may be a scalar, L<Bivio::UI::Widget|Bivio::UI::Widget>,
or array_ref which returns a scalar.

=head2 static new(hash_ref attrs) : Bivio::UI::HTML::Widget::Radio

Creates a Radio widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Draws the date field on the specified buffer.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $self->get('field');
    my($value) = UNIVERSAL::isa($self->get('value'), 'Bivio::Type::Enum')
        ? $self->get('value')
        : ${$self->render_attr('value', $source)};
    $$buffer .= '<input name="'
	    . $form->get_field_name_for_html($field)
	    . '"'
#TODO: is_equal?
	    . (defined($form->get($field))
		    && $value eq $form->get($field) ? ' checked="1"' : '')
	    . ' type="radio" value="'
	    . (ref($value) ? $value->to_html($value) :
		Bivio::HTML->escape($value))
	    . "\""
	    . ($fields->{auto_submit} ? ' onclick="submit()"' : '')
	    . ">&nbsp;";

    my($label) = $self->get('label');
    if (UNIVERSAL::isa($label, 'Bivio::UI::Widget')) {
	$label->render($source, $buffer);
    }
    else {
	my($p, $s) = Bivio::UI::Font->format_html('radio', $req);
	$label = $source->get_widget_value(@$label)
	    if ref($label);
	$$buffer .= $p . Bivio::HTML->escape($label) . $s;
    }
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
#TODO: Cache these?
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{auto_submit} = $self->get_or_default('auto_submit', 0);
#TODO: Probably should just wrap in a String widget.
    $self->get('label')->initialize_with_parent($self)
	if UNIVERSAL::isa($self->get('label'), 'Bivio::UI::Widget');
    return $self->SUPER::initialize;
}

=for html <a name="internal_new_args"></a>

=head2 internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $field, $value, $label, $attributes) = @_;
    return '"field" must be a defined scalar'
	unless defined($field) && !ref($field);
    return '"value" must be a scalar, array_ref, or Bivio::Type::Enum'
	unless defined($value)
	    && (!ref($value) || ref($value) eq 'ARRAY'
		|| UNIVERSAL::isa($value, 'Bivio::Type::Enum'));
    return {
	field => $field,
	value => $value,
	label => $label,
	($attributes ? %$attributes : ()),
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
