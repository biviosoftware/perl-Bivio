# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::SiteRoot;
use strict;
use Bivio::Base 'HTMLWidget.Link';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = shift;
    $self->put_unless_exists(
	value => vs_text('SiteRoot', $self->get('view_name_to_call')),
	href => [
	    $self->use('View.SiteRoot'),
	    '->format_uri',
	    $self->get('view_name_to_call'),
	    ['->get_request'],
	],
    );
    return $self->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('view_name_to_call');
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(view_name_to_call)], \@_);
}

1;
