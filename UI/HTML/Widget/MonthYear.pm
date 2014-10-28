# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::MonthYear;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    $self->put(
	values => [
	    _edit($self, 'month', $self->unsafe_get('want_two_digit_month'),
		  $self->unsafe_get('month_choices')),
	    _edit($self, 'year', undef, $self->unsafe_get('year_choices')),
	],
	join_separator => Join([
	    vs_blank_cell(2),
	    '/',
	    vs_blank_cell(2),
	]),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my($self, $base_field) = @_;
    return {
	base_field => $base_field,
    };
}

sub _edit {
    my($self, $suffix, $want_two_digit_month, $choices) = @_;
    return vs_edit(join('',
	$self->ancestral_get('form_class'), '.',
	$self->get('base_field'), '_', $suffix), {
	    wf_want_select => 1,
	    enum_sort => 'as_int',
	    $want_two_digit_month
	        ? (enum_display => 'get_two_digit_value')
	        : (),
	    $self->unsafe_get('unknown_label')
	        ? (unknown_label => $self->get('unknown_label'))
	        : (),
	    $choices ? (choices => $choices) : (),
	});
}

1;
