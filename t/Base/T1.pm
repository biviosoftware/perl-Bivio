# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::Base::T1;
use strict;
use Bivio::Base 'Type.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = __PACKAGE__->use('IO.Alert');

sub test_b_die {
    b_die('here');
    # DOES NOT RETURN
}

sub test_b_info {
    my($msg) = @_;
    $_A->set_printer(sub {$msg = shift});
    b_info('xyz');
    $_A->set_printer('STDERR');
    return $msg;
}

1;
