# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::AmountCell;
use strict;
use Bivio::Base 'HTMLWidget.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');
my($_FA) = __PACKAGE__->use('HTMLFormat.Amount');
my($_FA_ARGS) = [];
$_C->register(my $_CFG = {
    $_C->if_version(
	1 => sub {
	    return (
		column_align => 0,
		column_nowrap => 0,
		pad_left => 0,
		string_font => 0,
		want_parens => 0,
	    );
	},
	sub {
	    return (
		column_align => 'E',
		column_nowrap => 1,
		pad_left => 1,
		string_font => 'number_cell',
		want_parens => 1,
	    );
	},
    ),
    zero_as_blank => 0,
    decimals => 2,
    map(($_ => 'amount_cell'), qw(column_data_class cell_class)),
});
my($_CFG_KEYS) = [sort(keys(%$_CFG))];

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub initialize {
    my($self) = @_;
    $self->put(
	value => [sub {
		my($source, $amount) = @_;
	        return $_FA->get_widget_value(
		    $amount,
		    map($self->render_simple_attr($_, $source), qw(
		        decimals
			want_parens
			zero_as_blank
		    )),
		);
	    }, [$self->get('field')]],
    );
    $self->map_invoke(initialize_attr => [
	map([$_ => $_CFG->{$_}], @$_CFG_KEYS),
    ]);
    return $self->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $field, $attributes) = @_;
    return {
        field => $field,
	($attributes ? %$attributes : ()),
    };
}

1;
