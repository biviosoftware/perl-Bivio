# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MailHeader;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->initialize_attr(source => [sub {shift}]);
    $self->put_unless_exists(values => [
	map(
	    DIV_header(
		Join([
		    SPAN_label(vs_text_as_prose("MailHeader.$_")),
		    SPAN_value(vs_call($_ eq 'date' ? 'DateTime' : 'String',
			['->get_header', $_])),
		]),
		{
		    control => [
			sub {$_[1] =~ /\S/ ? 1 : 0},
			['->get_header', $_],
		    ],
		},
	    ),
	    qw(from to cc date subject),
	),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $source, $attributes) = @_;
    return {
	source => $source,
	($attributes ? %$attributes : ()),
    };
}

1;
