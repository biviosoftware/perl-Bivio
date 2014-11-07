# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::ViewShortcuts;
use strict;
use Bivio::Base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_FTM) = b_use('XHTMLWidget.ForumTaskMenu');
my($_LABEL_OFFSET) = _offset(b_use('XHTMLWidget.FormFieldLabel')->COL_CLASS);
my($_EDIT_COL_CLASS) = 'col-sm-6';

sub vs_inline_form {
    my($self, $model, $cols, $attrs) = @_;
    my($values) = [];
    foreach my $v (@$cols) {
	if ($v->isa('Bivio::UI::HTML::Widget::Select')) {
	    $v->put(class => 'form-control');
	}
	push(@$values, DIV($v, 'form-group'));
    }
    return Form(
	$model,
	Join($values, ' '),
	{
	    class => 'form-inline',
	    $attrs ? %$attrs : (),
	},
    );
}

sub vs_list {
    return shift->vs_paged_list(@_);
}

sub vs_paged_list {
    my($self, $model, $columns) = @_;
    my($table) = shift->SUPER::vs_paged_list(@_);
    # want tables with few columns (like mail message list)
    # to render tighter on large display, avoids wall-to-wall text
    my($extra_class) = @$columns <= 3 ? ' col-lg-9' : '';
    return DIV_row(
	DIV(
	    $table->put(class => 'table table-hover'),
	    $extra_class,
	),
    );
}

sub vs_placeholder_form {
    my($proto, $model, $rows, $attrs) = @_;
    $attrs ||= {};
    $attrs->{is_placeholder_form} = 1;

    foreach my $row (@$rows) {
	next unless $row;
#TODO: need to move detection to vs_simple_form_container() instead	
	if (! ref($row) && $row !~ /button/) {
	    $row = [$row, {
		PLACEHOLDER => vs_text($row),
	    }];
	}
	elsif (ref($row) eq 'ARRAY'
	    && $row->[0] && ! ref($row->[0])
	    && $row->[0] !~ /button/
	    && ref($row->[1]) eq 'HASH') {
	    $row->[1]->{PLACEHOLDER} = vs_text($row->[0]);
	}
    }
    return $proto->vs_simple_form($model, $rows, $attrs);
}

sub vs_put_pager {
    my($proto, $model, $attrs) = @_;
    view_put(vs_pager => Pager({
	list_class => $model,
	$attrs ? %$attrs : (),
    }));
    $proto->vs_put_seo_list_links($model);
    return;
}

sub vs_simple_form {
    my($self) = @_;
    return shift->SUPER::vs_simple_form(@_)->put(
	class => 'form-horizontal',
    );
}

sub vs_simple_form_container {
    my($self, $values, $form_attrs) = @_;
    my($rows) = [];
    my($is_placeholder_form) = $form_attrs->{is_placeholder_form};
    my($left_offset) = $is_placeholder_form
	? ''
	: $_LABEL_OFFSET;

    foreach my $row (@$values) {
	my($label, $form_field, @extra) = @$row;
	b_die('extra values in simple form: ', [@extra])
	    if @extra;
	if (($is_placeholder_form && $form_field) || _is_blank_cell($label)) {
	    ($label, $form_field) = ($form_field, undef);
	    $label ||= vs_blank_cell();
	}
	my($row);

	if (! $form_field && $label
		&& ($label->unsafe_get('cell_class') || '') eq 'sep') {
	    $row = DIV_row(DIV($label, 'well col-sm-offset-1 col-sm-8'));
	}
	else {
	    my($edit_col_class)
		= $label->unsafe_get('edit_col_class')
		    || $form_attrs->{edit_col_class}
		    || $_EDIT_COL_CLASS;
	    $row = DIV(Join([
		$form_field
		    ? $label
		    : DIV(
			$label,
			"$left_offset $edit_col_class",
		    ),
		$form_field
		    ? DIV(
#TODO: only really puts it on other widgets like a static text DIV
# FormField() returns a Join() and class gets ignored
			$form_field->put(class => 'form-control-static'),
			$edit_col_class,
		    )
		    : (),
	    ]), 'form-group');
	}
	my($control) = ($label && $label->unsafe_get('row_control'))
	    || ($form_field && $form_field->unsafe_get('row_control'));
	$row->put(control => $control)
	    if $control;
	push(@$rows, $row);
    }
    return Join($rows);
}

sub vs_xhtml_title {
    my($proto) = @_;
    return If(
        [$_FTM, '->is_top_level_tab', ['->req']],
        '',
        $proto->vs_text_as_prose('xhtml_title'),
    );
}

sub _is_blank_cell {
    my($label) = @_;
#TODO: hack to ignore vs_blank_cell()
    if ($label->isa('Bivio::UI::Widget::Join')) {
	my($values) = $label->get('values');
	return 1
	    if (@$values == 1 && $values->[0] eq '&nbsp;')
    }
    return 0;
}

sub _offset {
    my($class) = @_;
    $class =~ s/(\-\d+)$/-offset$1/ || b_die();
    return $class;
}

1;
