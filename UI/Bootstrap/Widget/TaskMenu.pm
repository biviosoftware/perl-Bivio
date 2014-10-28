# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::TaskMenu;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_TMO) = b_use('XHTMLWidget.TaskMenuOverride');

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(
	tag => 'ul',
    )->SUPER::initialize(@_);
}

sub internal_drop_down_widget {
    my($self, $buffers) = @_;
#TODO: hacked to determine if item in dropdown is active    
    my($active) = grep($_ =~ /[ "]active[ "]/, @$buffers);
    return DropDown(
	$self->get('want_more_label'),
	UL(Join($buffers)),
    )->put(class => $active ? 'dropdown active' : 'dropdown');
}

sub internal_wrap_widget {
    my($self, $w, $cfg) = @_;

    if ($self->get('tag') eq 'ul') {
	return $w->unsafe_get('task_menu_no_wrap')
	    ? $w
	    : LI($w);
    }
    return shift->SUPER::internal_wrap_widget(@_);
}

sub render_tag_value {
    my($self, $source) = @_;
    my($attrs) = $_TMO->unsafe_get_override_attributes($source);
    $self->put(%$attrs)
	if $attrs;
    return shift->SUPER::render_tag_value(@_);
}

1;
