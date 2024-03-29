# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Hidden;
use strict;
=head1 NAME

Bivio::UI::HTML::Widget::Hidden - hidden form field

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Hidden;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Hidden::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Hidden> draws a C<INPUT> tag with
attribute C<TYPE=HIDDEN>.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Hidden

Creates a Hidden widget.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
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
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    $fields->{prefix} = '<input type="hidden" name="';
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(string field) : hash_ref

=head2 static internal_new_args(string field, hash_ref attributes) : hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $field, $attributes) = @_;
    return '"field" attribute must be defined' unless defined($field);
    return {
        field => $field,
        ($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the hidden field.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
    $$buffer .= $fields->{prefix}
        . $form->get_field_name_for_html($fields->{field})
        . '" value="'
        . $form->get_field_as_html($fields->{field})
        . '" />';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
