# Copyright (c) 2006-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_X) = b_use('Search.Xapian');
my($_D) = b_use('Type.Date');
my($_RT) = b_use('Auth.RealmType');
my($_A) = b_use('IO.Alert');
my($_CL) = b_use('IO.ClassLoader');
my($_C) = b_use('IO.Config');

$_C->register(my $_CFG = {
    xapian_replicate_server_port => 1315,
    db_path => $_X->get_db_path,
    snapshot_dir => $_X->get_db_path . '/snapshot',
});

sub USAGE {
    return <<'EOF';
usage: b-search [options] command [args..]
commands
  rebuild_db [after_date] -- reload entire search database, optionally files modified after date
  rebuild_realm [after_date] -- reindex all files in the current realm, optionally files modified after date
  replicate_db [failover_host] -- create/update local online snapshot and optionally rsync it to 'failover-host' 
EOF
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub rebuild_db {
    sub REBUILD_DB {[[qw(?after_date Date)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->assert_not_root;
    $self->are_you_sure('Rebuild Xapian database?');
    my($req) = $self->req;
    $_X->acquire_lock($req);
    $_X->destroy_db($req);
    my($realms) = b_use('Type.StringArray')
	->new(_map_classes(sub {@{shift->realms_for_rebuild_db($req)}}))
	->sort_unique;
    $self->commit_or_rollback;
    b_info('Rebuilding ', $realms->as_length, ' realms');
    $realms->do_iterate(
	sub {
	    my($r) = @_;
	    return 1
		if $_RT->is_default_id($r);
	    $req->with_realm(
		$r,
		sub {
		    b_info($self->rebuild_realm($bp->{after_date}));
		    return;
		},
	    );
	    return 1;
	},
    );
    return;
}

sub rebuild_realm {
    sub REBUILD_REALM {[[qw(?after_date Date)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->assert_not_root;
    $self->usage_error('realm must be specified')
	if $self->req('auth_realm')->is_default;
    my($req) = $self->initialize_fully;
    my($i) = 0;
    my($j) = 0;
    my($commit) = sub {
	$self->commit_or_rollback;
	$_A->reset_warn_counter;
	return;
    };
    $_X->acquire_lock($req);
    _map_classes(
	sub {
	    my($class) = @_;
	    $class->do_iterate_realm_models(
		sub {
		    my($it) = @_;
		    if (0 == ++$i % 100) {
			$commit->();
			$_X->acquire_lock($req);
			b_info($i)
		            if $i > 1;
		    }
		    return 1
			if $bp->{after_date}
			&& $_D->is_less_than(
			$it->get('modified_date_time'),
			$bp->{after_date},
		    );
		    $_X->update_model($req, $it);
		    $j++;
		    return 1;
		},
		$req,
	    );
	},
    );
    $commit->();
    return $self->req(qw(auth_realm owner))->as_string . ": $j objects";
}

sub replicate_db {
    my($self) = @_;
    sub REPLICATE_DB {[[qw(?failover_host String)]]}
    my($bp);
    ($self, $bp) = shift->parameters(\@_);
    _make_db_snapshot($self);
    return
	unless defined($bp->{failover_host});
    _copy_db_snapshot_to_failover($self, $bp->{failover_host});
    return;		       
}

sub  _copy_db_snapshot_to_failover {
    my($self, $failover_host) = @_;
    my($replica_dir);
    for my $suffix (0 .. 9) {
	my($d) = $_CFG->{snapshot_dir} . '/replica_' . $suffix;
	if (-e $d) {
	    $replica_dir = $d;
	    last;
	}
    }
    b_die('replica directory does not exist')
	unless defined($replica_dir);
    my($output) = $self->piped_exec([
	'rsync',
	'-avrzS',
	'--delete',
	$replica_dir,
	$failover_host
	    . ':'
	    . $_CFG->{db_path},
    ]);
    _trace($$output);
    return;
}

sub _make_db_snapshot {
    my($self) = @_;
    my($pid) = fork();
    b_die('cannot fork')
	unless defined ($pid);
    if ($pid == 0) {
	my($output) = $self->piped_exec([
	    'xapian-replicate-server',
	    '-I',
	    '127.0.0.1',
	    '-p',
	    $_CFG->{xapian_replicate_server_port},
	    '--one-shot',
	    $_CFG->{db_path},
	]);
	_trace($$output);
	exit(0);
    }
    my($output) = $self->piped_exec([
	'xapian-replicate',
	'--verbose',
	'--one-shot',
	'-h',
	'127.0.0.1',
	'-p',
	 $_CFG->{xapian_replicate_server_port},
	'-m',
	'.',
	$_CFG->{snapshot_dir},
    ]);
    _trace($$output);
    # --one-shot means server should exit x    
    kill(9, $pid);    
    return;
}


sub _map_classes {
    my($op) = @_;
    return [map(
	$op->(b_use('SearchParser', $_)),
	@{$_CL->list_simple_packages_in_map('SearchParser')},
    )];
}

1;
