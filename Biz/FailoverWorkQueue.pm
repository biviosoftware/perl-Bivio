# Copyright (c) 2005-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::FailoverWorkQueue;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
b_use('IO.Trace');
our($_TRACE);
my($_C) = b_use('IO.Config');
my($_FWQO) = b_use('Type.FailoverWorkQueueOperation');

$_C->register(my $_CFG = {
    enable => 0,
});


sub create_file {
    my($proto, $file_name) = @_;
    _insert_into_work_queue($file_name, $_FWQO->CREATE_FILE->as_sql_param);
    return;
}

sub delete_file {
    my($proto, $file_name) = @_;
    _insert_into_work_queue($file_name, $_FWQO->DELETE_FILE->as_sql_param);
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _insert_into_work_queue {
    my($file_name, $operation) = @_;
    return
        unless $_CFG->{enable};
    _trace($file_name, $operation) if $_TRACE;
    b_use('SQL.Connection')->execute(
        q{INSERT INTO  failover_work_queue_t (failover_work_queue_id, operation, file_name)
              VALUES  (nextval('failover_work_queue_s'), ?, ?)},
        [$operation, $file_name]);
    return;
}


1;
