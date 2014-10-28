# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Method;
use strict;
use Bivio::Base 'UI.View';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub absolute_path {
    return shift->get('view_method');
}

sub compile {
    my($self) = @_;
    $self->pre_compile;
    my($m) = $self->get('view_method');
    $self->$m();
    return;
}

sub pre_compile {
    my($self) = @_;
    view_parent('base')
	unless $self->unsafe_get('view_parent');
    return;
}

sub unsafe_new {
    my($proto, $name, $facade) = @_;
    return $name !~ /^internal_/ && $proto->can($name)
	? $proto->new({view_method => $name})
	: undef;
}

1;
