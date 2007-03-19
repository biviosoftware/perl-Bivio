# Copyright (c) 2000-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML;
use strict;
use base 'Bivio::UI::Constant';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto, ['Color', 'Font', 'Text']);
    return;
}

sub internal_initialize_value {
    my($self, $value) = @_;
    shift->SUPER::internal_initialize_value(@_);
    $value->{value}->initialize
	if $self->is_blessed($value->{value}, 'Bivio::UI::Widget');
    return;
}

1;
