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

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item size : int (required)

How wide is the field represented.  (maxlength comes from the
field's type.)

=back

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Type::Password;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<input name='
		.$form->get_field_name_for_html($field)
		.' type='
		.($type->isa('Bivio::Type::Password') ? 'password' : 'text')
		.' size='.$fields->{size}.' maxlength='.$type->get_width();
	$fields->{initialized} = 1;
    }
    $$buffer .= $fields->{prefix};
    $$buffer .= ' value="'.$form->get_field_as_html($field).'">';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
