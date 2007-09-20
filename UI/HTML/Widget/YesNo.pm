# Copyright (c) 2001-2005 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::YesNo;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::HTML::Widget::YesNo> displays a Boolean field as Yes/No
# radios.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI] ||= {};
    return if $fields->{yes_widget};
    foreach my $name (qw(yes no)) {
	$fields->{$name.'_widget'} = Bivio::UI::HTML::Widget::String->new(
	    ucfirst($name), 'radio'
	)->put_and_initialize(parent => $self);
    }
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($form) = $source->get_request->get_widget_value(
	$self->ancestral_get('form_model'));
    foreach my $name (qw(yes no)) {
	my($value) = $name eq 'yes' ? 1 : 0;
	$$buffer .= '<input name="'
	    . $form->get_field_name_for_html($self->get('field'))
	    . qq{" type=radio value="$value"};

	if (($form->get($self->get('field')) || 0) eq $value) {
	    $$buffer .= ' checked';
	}

	$$buffer .= ' />&nbsp;';
	$fields->{$name . '_widget'}->render($source, $buffer);
	$$buffer .= ' ';
    }
    return;
}

1;
