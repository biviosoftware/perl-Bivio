# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::JSONValueLabelPairList;
use strict;
use Bivio::Base 'Widget.ControlBase';
b_use('UI.ViewLanguageAUTOLOAD');

my($_M) = b_use('Biz.Model');
my($_JSON) = b_use('MIME.JSON');

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($list) = $source->req($self->get('source_name'));
    my($data) = [];
    $list->reset_cursor;
    while($list->next_row) {
	my($v) = '';
	$self->get('value_widget')->render($list, \$v);
	my($l) = '';
	$self->get('label_widget')->render($list, \$l);
	push(
	    @$data,
	    {
		value => $v,
		label => $l,
	    },
	);
    }
    $$buffer = ${$_JSON->to_text($data)};
    return;
}

sub initialize {
    my($self, $source) = @_;
    $self->put(
	source_name => $_M->get_instance($self->get('list_class'))->package_name);
    foreach my $w (qw(value_widget label_widget)) {
	$self->get($w)->initialize_with_parent($self, $source);
    }
    return shift->SUPER::initialize(@_);
}

1;
