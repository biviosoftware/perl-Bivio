# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::Constant;
use strict;
use Bivio::Base 'FacadeComponent.Text';


sub REGISTER_PREREQUISITES {
    return ['Text'];
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
