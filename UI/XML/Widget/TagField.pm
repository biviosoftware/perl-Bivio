# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::TagField;
use strict;
use Bivio::Base 'XMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->initialize_attr(field_name => sub {$self->get('tag')});
    $self->initialize_attr(value => sub {Field($self->get('field_name'))});
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $tag, @rest) = @_;
    return {
	tag => $tag,
	!@rest ? () : (
	    ref($rest[0]) eq 'HASH' ? () : (field_name => shift(@rest)),
	    ref($rest[0]) ? %{shift(@rest)} : (),
	),
    };
}

1;
