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

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::FormButton::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormButton> a form specific submit button.

Font is always C<FORM_SUBMIT>.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item text : string (required)

The button text.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::FormButton

Creates a new Form Button widget.

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

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    $fields->{text} = $self->get('text');
    $fields->{prefix} = '<input type=submit name=';

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
    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    my($req) = $source->get_request;
    my($p, $s) = Bivio::UI::Font->format_html('form_submit', $req);
    my($value) = $p.$fields->{prefix}
	    .$form->get_field_name_for_html($field)
		    .' value ="'.$fields->{text}.'">'.$s;

    $$buffer .= $value;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
