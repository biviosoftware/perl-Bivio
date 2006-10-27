# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateField;
use strict;
$Bivio::UI::HTML::Widget::DateField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::DateField::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::DateField - a date field for forms

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::DateField;
    Bivio::UI::HTML::Widget::DateField->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::ControlBase>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::DateField::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::DateField> is a date field for forms.

B<Don't use this for DateTime values.>

=head1 ATTRIBUTES

=over 4

=item allow_undef : boolean [false]

Allow undef for field, i.e. don't fill in with now.

=item event_handler : Bivio::UI::Widget []

If set, this widget will be initialized as a child and must
support a method C<get_html_field_attributes> which returns a
string to be inserted in this fields declaration.
I<event_handler> will be rendered before this field.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=back

=cut

#=IMPORTS
use Bivio::UI::DateTimeMode;
use Bivio::UI::HTML::Format::DateTime;

#=VARIABLES
my($_D) = Bivio::Type->get_instance('Date');
my(@_ATTRS) = qw(
    allow_undef
    event_handler
    field
    form_model
);

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="accepts_attribute"></a>

=head2 static accepts_attribute(string attr) : boolean

Does the widget accept this attribute?

=cut

sub accepts_attribute {
    my(undef, $attr) = @_;
    return grep($_ eq $attr, @_ATTRS) ? 1 : 0;
}

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Draws the date field on the specified buffer.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$self->ancestral_get('form_model')});
    my($field) = ${$self->render_attr('field', $source)};

#TODO: Merge with Text.  Too much duplicated code.
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    my($width) = $_D->get_width;
    $$buffer .= $p
	. '<input name="'
	. $form->get_field_name_for_html($field)
	. '" type="text" size="'
	. ($width  + 2)
	. qq{" maxlength="$width"};
    my($h) = $self->unsafe_get('event_handler');
    $h = $self->unsafe_resolve_widget_value($h, $source)
	if $h;
    $$buffer .= ' ' . $h->get_html_field_attributes($field, $source)
	if $h;
    $$buffer .= ' disabled="1"'
	unless $form->is_field_editable($field);
    my($b) = '';
    $$buffer .= ' value="'
	. ($form->get_field_error($field) ? $form->get_field_as_html($field)
	    : $_D->to_html(
		$form->get($field)
		    or $self->unsafe_render_attr('allow_undef', $source, \$b)
			&& $b ? undef
		    : $_D->local_today
	)) . qq{" />$s};
    # Handler is rendered after, because it probably needs to reference the
    # field.
    $h->render($source, $buffer)
	if $h;
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->map_invoke(
	'unsafe_initialize_attr',
	[@_ATTRS],
    );
    return;
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns this widget's config for
L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.

=cut

sub internal_as_string {
    return shift->unsafe_get('field');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args() :  hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    return shift->internal_compute_new_args(['field'], \@_);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
