# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::File;
use strict;
$Bivio::UI::HTML::Widget::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::File - a file field for forms

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::File;
    Bivio::UI::HTML::Widget::File->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::File::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::File> is a file field for forms.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item size : int (required)

How wide is the field represented.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::File

Creates a File widget.

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

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    # Make sure required attribute defined
    $self->get('size');
    $fields->{is_first_render} = 1;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the file field on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    if ($fields->{is_first_render}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<input name='
		.$form->get_field_name_for_html($field)
		.' type=file size='.$self->get('size');
	$fields->{is_first_render} = 0;
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
