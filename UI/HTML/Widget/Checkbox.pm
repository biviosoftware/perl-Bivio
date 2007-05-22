# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Checkbox;
use strict;
$Bivio::UI::HTML::Widget::Checkbox::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Checkbox::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Checkbox - form checkbox

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Checkbox;
    Bivio::UI::HTML::Widget::Checkbox->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Checkbox::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Checkbox> is a form checkbox

=head1 ATTRIBUTES

=over 4

=item auto_submit : boolean [0]

Should a click submit the form?

=item event_handler : Bivio::UI::Widget []

If set, this widget will be initialized as a child and must
support a method C<get_html_field_attributes> which returns a
string to be inserted in this fields declaration.
I<event_handler> will be rendered before this field.

=item field : string (required)

Name of the form field.

=item form_class : string (required, inherited)

Class name of form are we dealing with.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item label : any [see description]

String, widget value, widget, etc. to be rendered as label.  Font
should be I<checkbox> if you are creating your own widget.

If I<label> is C<undef>, will look up in Bivio::UI::Text using I<field>
and I<form_class>.

If I<label> is the empty string, renders nothing.

=item value : string [1]

The checkbox's submit value.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::Checkbox

Creates a Checkbox widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
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
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    $fields->{value} = $self->get_or_default('value', 1);
    $fields->{auto_submit} = $self->get_or_default('auto_submit', 0);
    my($l) = $self->unsafe_get('label');
    $fields->{label} = $self->unsafe_initialize_attr('label');
    $fields->{label} = $_VS->vs_text(
	$self->ancestral_get('form_class')->simple_package_name,
	$fields->{field})
	unless defined($fields->{label});
    $fields->{label} = $_VS->vs_string($fields->{label}, 'checkbox')
	if !UNIVERSAL::isa($fields->{label}, 'Bivio::UI::Widget')
	    # Works ok even if a ref()
	    && length($fields->{label});
    $fields->{label}->put_and_initialize(parent => $self)
	if $fields->{label};
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

Draws the checkbox on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    $$buffer .= '<input name="'
	. $form->get_field_name_for_html($field)
	. '"';
    $$buffer .= ' checked="1"'
	if $form->get($field);
    $$buffer .= ' '
	. $fields->{handler}->get_html_field_attributes($field, $source)
	if $fields->{handler};
    $$buffer .= ' disabled="1"'
	if $self->get_or_default('is_read_only',
            ! $form->is_field_editable($field));
    $$buffer .= ' type="checkbox" class="checkbox" value="'
	. $fields->{value} . '"';
    $$buffer .= ' onclick="submit()"'
	if $fields->{auto_submit};
    $$buffer .= " />";
    if ($fields->{label}) {
	$$buffer .= "\n";
	$fields->{label}->render($source, $buffer);
    }
    # Handler is rendered after, because it probably needs to reference the
    # field.
    $fields->{handler}->render($source, $buffer)
	if $fields->{handler};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
