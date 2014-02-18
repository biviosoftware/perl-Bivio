# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Bootstrap;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_generate_css {
    my($proto, $req) = @_;
    return $proto->get_instance('LocalFilePlain')
	->execute($req, ShellUtil_Project()->generate_bootstrap_css);
}

1;
