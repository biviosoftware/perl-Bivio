# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Radio;
use strict;
$Bivio::UI::HTML::Widget::Radio::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Radio - a radio input field

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

String label to use.

=item value : Bivio::Type::Enum (required)

Value of button.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::UI::Font;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::Radio

Creates a Radio widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::ControlBase::new(@_);
    $self->{$_PACKAGE} = {};
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
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    my($value) = $fields->{value};

    # first render initialization
    unless ($fields->{initialized}) {
	$fields->{initialized} = 1;
	$fields->{prefix} = '<input name=';
	$fields->{suffix} = ' type=radio value="'
		.$value->to_html($value)
		."\""
		.($fields->{auto_submit} ? ' onclick="submit()"' : '')
		.">&nbsp;";
    }

    my($p, $s) = Bivio::UI::Font->format_html('radio', $req);

    my($label) = $self->get('label');
    $label = $source->get_widget_value(@$label) if ref($label);
    $$buffer .= $fields->{prefix}
	    .$form->get_field_name_for_html($field)
#TODO: is_equal?
	    .(defined($form->get($field))
		    && $value eq $form->get($field) ? ' checked' : '')
	    .$fields->{suffix}
 	    .$p.Bivio::HTML->escape($label).$s;
    return;
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
    $fields->{value} = $self->get('value');
    $fields->{auto_submit} = $self->get_or_default('auto_submit', 0);
    return $self->SUPER::initialize();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
