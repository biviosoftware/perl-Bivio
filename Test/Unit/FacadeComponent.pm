# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::FacadeComponent;
use strict;
use Bivio::Base 'TestUnit.Unit';


sub new_unit {
    my($proto, $class_name, $attrs, @rest) = @_;
    my($req) = b_use('Test.Request')->initialize_fully;
    $attrs ||= {};
    $attrs->{create_object} ||= sub {
        my($self) = shift->get('test');
        return $self->builtin_class->get_from_source($self->builtin_req);
    };
    return shift->SUPER::new_unit($class_name, $attrs, @rest);
}

sub unit {
    return shift->unit_from_method_group(@_);
}

1;
