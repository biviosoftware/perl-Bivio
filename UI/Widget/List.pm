# Copyright (c) 2005-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::List;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::UI::HTML::WidgetFactory;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    foreach my $old (qw(source_name separator)) {
	$self->die($old, undef, 'attribute no longer supported')
	    if $self->has_keys($old);
    }
    my($m) = Bivio::Biz::Model->get_instance($self->get('list_class'));
    my($class) = $m->simple_package_name;
    my($list) = $m->isa('Bivio::Biz::ListFormModel')
	? $m->get_instance($m->get_list_class)
	: $m;
    my($name) = 0;
    $self->put(
	columns => [map({
	    my($c) = ref($_) ? $_
		: $m->has_fields($_)
		? Bivio::UI::HTML::WidgetFactory->create("$class.$_")
		: Bivio::UI::HTML::WidgetFactory->create(
		    $list->simple_package_name . ".$_",
		    {
			field => $_,
			value => [['->get_list_model'], $_],
		    });
	    $self->initialize_value($name++, $c);
	    $c;
	} @{$self->get('columns')})],
    );
    $self->unsafe_initialize_attr('empty_list_widget');
    return;
}

sub internal_as_string {
    return shift->unsafe_get('list_class');
}

sub internal_new_args {
    my(undef, $list_class, $columns, $attributes) = @_;
    return '"list_class" must be a defined scalar'
	unless defined($list_class) && !ref($list_class);
    return '"columns" must be an array_ref'
	unless ref($columns) eq 'ARRAY';
    return {
	list_class => $list_class,
	columns => $columns,
	($attributes ? %$attributes : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($model) = $source->get_request
	->get('Model.' . $self->get('list_class'));
    unless ($model->get_result_set_size) {
	$self->unsafe_render_attr('empty_list_widget', $source, $buffer);
	return;
    }
    my($need_sep) = 0;
    $model->do_rows(sub {
        my($name) = 0;
	my($b) = '';
	foreach my $c (@{$self->get('columns')}) {
	    $self->unsafe_render_value($name++, $c, $model, \$b);
	}
	$self->unsafe_render_attr('row_separator', $model, $buffer)
	    if length($b) && $need_sep;
	$need_sep ||= length($b);
	$$buffer .= $b;
	return 1;
    });
    return;
}

1;
