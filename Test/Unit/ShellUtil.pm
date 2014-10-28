# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::ShellUtil;
use strict;
use Bivio::Base 'TestUnit.Unit';


sub new_unit {
    my($proto) = shift;
    my($res) = $proto->SUPER::new_unit(@_);
    $proto->use('TestUnit.Request')->get_instance;
    return $res;
}

sub unit {
    my($self, $cases) = @_;
    return $self->SUPER::unit([
	$self->builtin_class => [
	    main => $cases,
	],
    ]);
}

1;
