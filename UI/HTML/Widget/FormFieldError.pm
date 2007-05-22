# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormFieldError;
use strict;
$Bivio::UI::HTML::Widget::FormFieldError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::FormFieldError::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::FormFieldError - an error message for a form field

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormFieldError;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::FormFieldError::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormFieldError> an error message for a form field

=head1 ATTRIBUTES

=over 4

=item field : string (required)

The model field name.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item label: string

=item label: array_ref

The label string or widget value used in the error message.

=back

=cut

#=IMPORTS
use Bivio::UI::Font;
use Bivio::UI::HTML::FormErrors;
use Bivio::UI::FormError;

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::DescriptiveFormField

Creates a new DescriptiveFormField widget.

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

Initializes the widgets internal structures.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{field} = $self->get('field');
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{label} = $self->unsafe_get('label') || '';
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Appends the value of the widget to I<buffer>.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;

    # check for errors.  Multi-field fields (ref(field)) handle errors
    # themselves.
    my($model) = $req->get_widget_value(@{$fields->{model}});
    if ($model->in_error && !ref($fields->{field})) {
	my($errors) = $model->get_errors;

	my($error) = $errors->{$fields->{field}};
	if (defined($error)) {
	    my($p, $s) = Bivio::UI::Font->format_html('form_field_error',
		    $req);
	    $$buffer .= $p
		. Bivio::UI::Facade->get_from_request_or_self($req)
		    ->get_or_default(
			'FormError', 'Bivio::UI::HTML::FormErrors')
		    ->to_html(
			$source,
			$model,
			$fields->{field},
			ref($fields->{label}) eq 'ARRAY'
			    ? $source->get_widget_value(@{$fields->{label}})
			    : $fields->{label},
			$error,
		    )
		. $s
		. "<br>\n";
	}
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
