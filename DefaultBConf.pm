# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::DefaultBConf;
use strict;
use base 'Bivio::BConf';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub merge_overrides {
    my($proto) = @_;
    return Bivio::IO::Config->merge_list(
	{
	    $proto->merge_class_loader,
	    $proto->merge_http_log,
	},
	$proto->default_merge_overrides({
	    version => $proto->CURRENT_VERSION,
	    root => 'Bivio',
	    prefix => 'b',
	    owner => 'bivio Software, Inc.',
	}),
	shift->SUPER::merge_overrides(@_),
    );
}

1;
