# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::Tag;
use strict;
use Bivio::Base 'HTMLWidget.Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MAP_ATTRS) = {
  'div.title' => {
      tag => 'h3',
      class => 'b_title',
  },
  'div.err_title' => {
      class => 'alert alert-warning',
  },
  'div.desc' => {
      tag => 'p',
      class => 'help-block',
  },
};

sub initialize {
    my($self) = @_;
    shift->SUPER::initialize(@_);
    my($key) = join('.', $self->get('tag'), $self->unsafe_get('class') || '');
    my($values) = $_MAP_ATTRS->{$key};
    $self->put(%$values)
	if $values;
    return;
}

1;
