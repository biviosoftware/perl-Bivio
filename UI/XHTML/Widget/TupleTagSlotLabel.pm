# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TupleTagSlotLabel;
use strict;
use Bivio::Base 'XHTMLWidget.FormFieldLabel';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CB) = __PACKAGE__->use('XHTMLWidget.ControlBase');

sub initialize {
    my($self) = @_;
    $self->initialize_attr(
	label => After(
	    String(vs_form_method_call($self, 'tuple_tag_slot_label')),
	    ':',
	),
    );
    $self->initialize_attr(
	row_control => vs_form_method_call($self, 'tuple_tag_slot_label'));
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    shift;
    return $_CB->internal_compute_new_args([qw(field ?class)], \@_);
}

1;
