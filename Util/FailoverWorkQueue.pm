# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::FailoverWorkQueue;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
b_use('IO.Trace');
our($_TRACE);
my($_A) = b_use('IO.Alert');
my($_C) = b_use('IO.Config');
my($_D) =  b_use('Bivio.Die');
my($_F) = b_use('IO.File');
my($_SC) = b_use('SQL.Connection');

$_C->register(my $_CFG = {
    retry_sleep_seconds => 5,
    idle_sleep_seconds => 10,
    work_items_per_run => 100,
});


sub USAGE {
    return <<'EOF';
usage: b-failoverworkqueue [options] command [args...]
commands:
    live_process_failover_work_items failover-host -- run on 'live' machine to process the work items on the queue
EOF
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub live_process_failover_work_items {
    my($self, $failover_host) = @_;
    b_die('must specify failover-host')
        unless defined($failover_host);
    my($connection) = b_use('SQL.Connection')->get_instance;
    while (1) {
        my($statement) = $connection->execute(
            'SELECT failover_work_queue_id, operation, file_name from failover_work_queue_t LIMIT ?',
            [$_CFG->{work_items_per_run}]
        );
        my($file_names) = [];
        while (my $rows = $statement->fetchrow_hashref) {
            my($sth) = $connection->execute(
                'delete from failover_work_queue_t '
                    . ' WHERE entry_id = ?',
                [$rows->{entry_id}]);
            push(@$file_names, $rows->{file_name}); 
        }
        if (@$file_names == 0) {
             _trace('nothing to do, retrying in  ', $_CFG->{idle_sleep_seconds}, ' seconds');
            sleep($_CFG->{idle_sleep_seconds});
            next;
        }
        _trace($file_names);
        if (_synced_files($self, $file_names, $failover_host)) {
            $connection->commit;
        }
        else {
            _trace('rsync failed, retrying in ', $_CFG->{retry_sleep_seconds}, ' seconds');
            sleep($_CFG->{retry_sleep_seconds});
        }
    }
    return;    
}

sub _get_longest_common_prefix {
    my($prefix, @strings) = @_;
    foreach my $string (@strings) {
        chop($prefix)
            until ($string =~ /^$prefix/);
    }        
    return $prefix;
}


sub _synced_files {
    my($self, $file_names, $failover_host) = @_;
    my($prefix) = _get_longest_common_prefix(@$file_names);
    $prefix =~ s/[^\/]*$//;
    my(@include_options);
    foreach my $file_name (@$file_names) {
        $file_name =~ s/^$prefix//;
        push(@include_options, '--include', $file_name);        
    }        
    my($copied);
    $_D->catch_quietly(
        sub {
            $copied = $self->piped_exec([
                'rsync',
                '-avzlSr',
                '--delete',
                @include_options,
                '--include',
                '*/',
                '--exclude',
                '*',
                $prefix,
                $failover_host
                . ':'
                . $prefix
            ]);        
            return;
        });
    b_debug($$copied);
    _trace($$copied);
    return defined($copied);
}

1;
