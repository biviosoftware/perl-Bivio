# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TupleTagSlotValue;
use strict;
use Bivio::Base 'XHTMLWidget.Director';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CB) = __PACKAGE__->use('XHTMLWidget.ControlBase');

sub initialize {
    my($self) = @_;
    $self->initialize_attr('slot_label');
    my($value) = [sub {
	my($source) = @_;
	return $source->tuple_tag_find_slot_value(
	    $self->render_simple_attr(slot_label => $source));
    }];
    $self->put_unless_exists(
	control => [sub {
	     my($source) = @_;
	     return $source->tuple_tag_find_slot_type(
		 $self->render_simple_attr(slot_label => $source),
	     )->simple_package_name;
	}],
	values => {
	    Date => DateTime($value),
	    Integer => Integer($value),
	    Email => MailTo($value),
	},
	default_value => String($value),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('slot_label');
}

sub internal_new_args {
    shift;
    return $_CB->internal_compute_new_args([qw(slot_label)], \@_);
}

1;
