# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::RealmType;
use strict;
use Bivio::Base 'Type.EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile;
my($_S) = __PACKAGE__->use('Type.String');

sub as_property_model_class_name {
    return $_S->to_camel_case_identifier(shift->get_name);
}

1;
