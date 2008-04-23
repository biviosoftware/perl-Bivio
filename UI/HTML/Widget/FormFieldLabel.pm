# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormFieldLabel;
use strict;
$Bivio::UI::HTML::Widget::FormFieldLabel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::FormFieldLabel - label which can check for errors

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormFieldLabel;
    Bivio::UI::HTML::Widget::FormFieldLabel->new($attrs);

=cut

=head1 RELEASE SCOPE

bOP

=head1 EXTENDS

L<Bivio::UI::Widget::If>

=cut

use Bivio::UI::Widget::If;
@Bivio::UI::HTML::Widget::FormFieldLabel::ISA = ('Bivio::UI::Widget::If');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormFieldLabel> displays a string in
C<form_field_label>
or C<form_field_error_label> fonts.


=head1 ATTRIBUTES

=over 4

=item label : string (required)

Text to render for the visible label.

=item label : widget (required)

Widget to render for the label.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_IDI) = __PACKAGE__->instance_data_index;


=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Builds up the attributes for SUPER (If).

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI] ||= {};
    return if $fields->{initialized};
    my($label, $field) = $self->get('label', 'field');
    my($model) = $self->ancestral_get('form_model');
    $self->put(
	control => [$model, '->get_field_error', $field],
        control_on_value => $_VS->vs_join([
	    $_VS->vs_image('error_triangle', 'error here', {
	       align => 'SW',
	    }),
	    '&nbsp;',
	    $_VS->vs_string($label, 'form_field_error_label'),
	]),
	control_off_value =>  $_VS->vs_string($label, 'form_field_label'),
    );
    $self->SUPER::initialize;
    $fields->{initialized} = 1;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
