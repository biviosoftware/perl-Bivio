# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Method;
use strict;
use base 'Bivio::UI::View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    view_parent('base');
    return;
}

sub unsafe_new {
    my($proto, $name, $facade) = @_;
    return $proto->can($name) ? $proto->new({view_method => $name}) : undef;
}

1;
