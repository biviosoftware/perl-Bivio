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

sub get_widget_value {
    my($self, @tag) = @_;
    # I<tag_part>s are passed to L<get_value|"get_value">.
    #
    # If I<method_call> is passed (-E<gt>method), super will be called which
    # will call the method appropriately.
    # SUPER has code to handle ->, which we don't allow in names
    return $tag[0] =~ /^->/ ? $self->SUPER::get_widget_value(@tag)
	: $self->get_value(@tag);
}

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto, ['Text']);
    return;
}

sub internal_initialize_value {
    my($self, $value) = @_;
    $value->{value} = $value->{config};
    return;
}

1;
