# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::XML::Widget::JoinTagField;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(value => sub {
	WithModel($self->get('model') => Join([
	    map(TagField($_), @{$self->get('fields')}),
	])),
    });
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $model, $fields, $attrs) = @_;
    return {
	model => $model,
	fields => $fields,
	$attrs ? %$attrs : (),
    };
}

1;
