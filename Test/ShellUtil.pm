# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::ShellUtil;
use strict;
use Bivio::Base 'TestUnit.Unit';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub unit {
    my($self, $cases) = @_;
    return $self->SUPER::unit([
	$self->builtin_class => [
	    main => $cases,
	],
    ]);
}

1;
