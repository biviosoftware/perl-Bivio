# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Checkbox;
use strict;
$Bivio::UI::HTML::Widget::Checkbox::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Checkbox - form checkbox

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

=item field : string (required)

Name of the form field.

=item form_class : string (required, inherited)

Class name of form are we dealing with.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item label : string [get_form_field()]

String label to use.

If I<label> is C<undef>, will look up using I<field> with
L<Bivio::UI::Label::get_form_field|Bivio::UI::Label/"get_form_field">.

=item value : string [1]

The checkbox's submit value.

=back

=cut

#=IMPORTS
use Bivio::UI::Label;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::Checkbox

Creates a Checkbox widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
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
    $fields->{value} = $self->get_or_default('value', 1);
    $fields->{auto_submit} = $self->get_or_default('auto_submit', 0);
    my($l) = $self->unsafe_get('label');
    $l = Bivio::UI::Label->get_form_field(
	    $self->ancestral_get('form_class'), $fields->{field})
		unless defined($l);
    $fields->{label} = $_VS->vs_template_as_string(' '.$l, 'checkbox')
	    ->put_and_initialize(parent => $self);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the checkbox on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    unless ($fields->{initialized}) {
	$fields->{prefix} = '<input name=';
	$fields->{suffix} = ' type=checkbox value="'.$fields->{value}.'"';
	$fields->{suffix} .= ' onclick="submit()"' if $fields->{auto_submit};
	$fields->{suffix} .= '>';
	$fields->{initialized} = 1;
    }
    $$buffer .= $fields->{prefix}.$form->get_field_name_for_html($field);
    $$buffer .= ' checked' if $form->get($field);
    $$buffer .= $fields->{suffix};
    $fields->{label}->render($source, $buffer);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
