# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Constant;
use strict;
use base 'Bivio::UI::FacadeComponent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_value {
    my($proto, $name, $req) = @_;
    return ($proto->internal_get_value($name, $req)
        || $proto->die($name, 'not found')
    )->{value};
}
sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto);
    return;
}

sub internal_initialize_value {
    my($self, $value) = @_;
    my($v) = $value->{config};
    $v = $v->($self)
	if ref($v) eq 'CODE';
    $value->{value} = $v;
    return;
}

1;
