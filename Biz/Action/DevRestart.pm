# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::DevRestart;
use strict;
use Bivio::Base 'Action.JobBase';

my($_F) = b_use('IO.File');
my($_SENTINEL) = 'restart';

sub internal_execute {
    my($proto, $req) = @_;
    $req->assert_test;
    b_use('ShellUtil.HTTPD')->assert_in_exec_dir;
    $_F->write($_SENTINEL, time);
    CORE::exit(0);
    # DOES NOT RETURN
}

sub restart_requested {
    return 0
        unless -r $_SENTINEL;
    my($rs) = ${$_F->read($_SENTINEL)};
    unlink($_SENTINEL);
    b_die('not restarting, sentinel too old')
        if $rs + 20 < time;
    return 1;
}

1;
