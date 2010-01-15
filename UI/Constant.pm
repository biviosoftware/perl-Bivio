# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Constant;
use strict;
use Bivio::Base 'FacadeComponent.Text';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    my($proto) = @_;
    b_use('UI.Facade')->register($proto, ['Text']);
    return;
}

sub internal_assert_value {
    my($self, $value, $name) = @_;
    return $value;
}

sub internal_initialize_value {
    my($self, $value) = @_;
    $value->{value} = $value->{config};
    return;
}

1;
