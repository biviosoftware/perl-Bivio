# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::File;
use strict;
$Bivio::UI::HTML::Widget::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::File::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::File - a file field for forms

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::File;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::File::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::File> is a file field for forms.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item size : int (required)

How wide is the field represented.

=back

=cut

#=IMPORTS

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::File

Creates a File widget.

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
    my($fields) = $self->[$_IDI];
    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    if ($fields->{is_first_render}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<input type=file size="'.$self->get('size')
		.'" name="';
	$fields->{is_first_render} = 0;
    }
    $$buffer .= $fields->{prefix}.$form->get_field_name_for_html($field)
	    .'" value="'.$form->get_field_as_html($field)
	    .'" />';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
