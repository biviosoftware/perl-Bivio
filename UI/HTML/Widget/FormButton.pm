# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormButton;
use strict;
$Bivio::UI::HTML::Widget::FormButton::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::FormButton - a dynamic submit button

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormButton;
    Bivio::UI::HTML::Widget::FormButton->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::FormButton::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormButton> a form specific submit button.

Font is always C<FORM_SUBMIT>.

=head1 ATTRIBUTES

=over 4

=item attributes : string []

Attributes to be applied to the button.  C<StandardSubmit>
uses this to set "onclick=reset()".

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item label : string (required)

String label to use.

=item label : array_ref

If specified, the button text will be determined by calling
L<get_widget_value|"get_widget_value"> on the rendering source.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::FormButton

Creates a new Form Button widget.

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

    my($label) = $self->get('label');
    unless (ref($label)) {
	$label = Bivio::HTML->escape($label);
    }
    $fields->{label} = $label;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    my($p, $s) = Bivio::UI::Font->format_html('form_submit', $req);
    $$buffer .= $p.'<input type=submit name='
	    .$form->get_field_name_for_html($field).' value="'
	    .(ref($fields->{label})
		    ? Bivio::HTML->escape(
			    $source->get_widget_value(@{$fields->{label}}))
		    : $fields->{label})
	    .'" '.$self->get_or_default('attributes', '')
	    .'>'.$s;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
