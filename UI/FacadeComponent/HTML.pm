# Copyright (c) 2000-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::HTML;
use strict;
use Bivio::Base 'FacadeComponent.Constant';


sub REGISTER_PREREQUISITES {
    return [qw(Color Font Text Constant)];
}

sub internal_initialize_value {
    my($self, $value) = @_;
    shift->SUPER::internal_initialize_value(@_);
    $value->{value}->initialize
        if $self->is_blesser_of($value->{value}, 'Bivio::UI::Widget');
    return;
}

1;
