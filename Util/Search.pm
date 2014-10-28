# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.Trace');

our($_TRACE);
my($_X) = b_use('Search.Xapian');
my($_D) = b_use('Type.Date');
my($_RT) = b_use('Auth.RealmType');
my($_A) = b_use('IO.Alert');
my($_CL) = b_use('IO.ClassLoader');
my($_C) = b_use('IO.Config');
my($_PI) = b_use('Type.PrimaryId');
my($_DT) = b_use('Type.DateTime');
$_C->register(my $_CFG = {
    xapian_replicate_server_port => 1315,
    db_path => $_X->get_db_path,
    snapshot_dir => $_X->get_db_path . '/snapshot',
});
my($_F) = b_use('IO.File');
my($_SA) = b_use('Type.StringArray');

sub USAGE {
    return <<'EOF';
usage: b-search [options] command [args..]
commands
  audit_db [sleep]-- verify/fix all documents in all realms against search db, optionally sleep given seconds between commits
  audit_realm [sleep]-- verify/fix a realm's documents, optionally sleep given seconds between commits
  rebuild_db [after_date [sleep]] -- reload entire search database, optionally files modified after date, optionally sleep given seconds between commits
  rebuild_realm [after_date [sleep]] -- reindex all files in the current realm, optionally files modified after date, optionally sleep given seconds between commits
  replicate_db [failover_host] -- create/update local online snapshot and optionally rsync it to 'failover-host' 
EOF
}

sub audit_db {
    sub AUDIT_DB {[[qw(?sleep Amount)]]}
    my($self, $bp) = shift->parameters(\@_);
    my($req) = $self->req;
    $_X->acquire_lock($req);
    return _iterate_realms($self, 'audit_realm', [$bp->{sleep}], _resume($self));
}

sub audit_realm {
    sub AUDIT_REALM {[[qw(?sleep Amount)]]}
    my($self, $bp) = shift->parameters(\@_);
#TODO: Need to get all the docs for a realm, but how?
#Get a list of all docids in one go -- so we know what to delete.
#We'll verify after deleting all docids
#b_info(Search::Xapian::Database->new($_CFG->{db_path})->get_doccount);
#b_info(Search::Xapian::Database->new($_CFG->{db_path})->get_lastdocid);
#b_info(Bivio::Die->eval(sub {Search::Xapian::Database->new($_CFG->{db_path})->get_document(99999)}));
#enquire->get_mset->begin->inc->get_document (++)? then ->end
    return _do_realm(
	$self,
	sub {
	    my($it) = shift;
	    return 1
		unless my $values
		    = $_X->unsafe_get_values_for_primary_id(
			$it->get_primary_id,
			$it,
			{},
		    );
	    return $_DT->is_equal(
		$values->{modified_date_time},
		$it->get('modified_date_time'),
	    ) && $_PI->is_equal(
		$values->{author_user_id},
		$it->get('user_id'),
	    ) && $_PI->is_equal(
		$values->{'RealmOwner.realm_id'},
		$it->get('realm_id'),
	    ) ? 0 : 1;
	},
	$bp->{sleep},
    );
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub rebuild_db {
    sub REBUILD_DB {[[qw(?after_date Date)], [qw(?sleep Amount)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->are_you_sure('Rebuild Xapian database?');
    my($req) = $self->req;
    my($last_realm) = _resume($self);
    unless ($last_realm) {
	$self->are_you_sure('Are you sure you want to destroy the Xapian database?');
	$_X->acquire_lock($req);
	$_X->destroy_db($req);
    }
    return _iterate_realms(
	$self, 'rebuild_realm', [$bp->{after_date}], $last_realm);
}

sub rebuild_realm {
    sub REBUILD_REALM {[[qw(?after_date Date)], [qw(?sleep Amount)]]}
    my($self, $bp) = shift->parameters(\@_);
    return _do_realm(
	$self,
	sub {
	    my($it) = @_;
	    return $bp->{after_date}
		&& $_D->is_less_than(
		    $it->get('modified_date_time'),
		    $bp->{after_date},
		) ? 0 : 1;
	},
	$bp->{sleep},
    );
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

sub _copy_db_snapshot_to_failover {
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
    _trace($$output) if $_TRACE;
    return;
}

sub _do_realm {
    my($self, $cond, $sleep) = @_;
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
    my($rn) = $req->req(qw(auth_realm owner name));
    b_info("$rn: starting");
    _map_classes(
	sub {
	    my($class) = @_;
	    $class->do_iterate_realm_models(
		sub {
		    my($it) = @_;
		    $_X->acquire_lock($req);
		    $i++;
		    b_info($i)
			if $i % 100 == 0;
		    select(undef, undef, undef, $sleep)
			if $i % 10 == 0 && defined($sleep) && $sleep >= 0;
		    return 1
			unless $it->is_searchable
			&& $cond->($it);
		    $_X->update_model($req, $it);
		    $commit->();
		    $_X->acquire_lock($req);
		    $j++;
		    return 1;
		},
		$req,
	    );
	},
    );
    $commit->();
    return "$rn: updated $j objects";
}

sub _iterate_realms {
    my($self, $method, $method_args, $last_realm) = @_;
    $self->assert_not_root;
    my($req) = $self->req;
    my($realms) = $_SA
	->new(_map_classes(sub {@{shift->realms_for_rebuild_db($req)}}))
	->sort_unique;
    $realms = $_SA->new(
	$realms->map_iterate(
	    sub {
		my($r) = @_;
		$_SA->UNDERLYING_TYPE->compare($r, $last_realm) >= 0 ? $r : ();
	    },
	),
    ) if defined($last_realm);
    $self->commit_or_rollback;
    b_info($realms->as_length, ' realms');
    my($last_realm_file_name) = _last_realm_file_name($self->my_caller);
    $realms->do_iterate(
	sub {
	    my($r) = @_;
	    return 1
		if $_RT->is_default_id($r);
	    $_F->write($last_realm_file_name, $r);
	    $req->with_realm(
		$r,
		sub {
		    b_info($self->$method(@$method_args));
		    return;
		},
	    );
	    return 1;
	},
    );
    unlink($last_realm_file_name)
	if -f $last_realm_file_name;
    return $realms->as_array;
}

sub _last_realm_file_name {
    my($method) = @_;
    return "$method-last-processed-realm";
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
	_trace($$output) if $_TRACE;
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
    _trace($$output) if $_TRACE;
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

sub _resume {
    my($self) = @_;
    my($last_realm_file_name) = _last_realm_file_name($self->my_caller);
    my($last_realm);
    if (-f $last_realm_file_name) {
	my($answer) = $self->unsafe_get('force')
	    ? 'y'
	    : $self->readline_stdin(
		"Continue from last processed realm? (y or n) ");
	if ($answer =~ /^y$/i) {
	    $last_realm = ${$_F->read($last_realm_file_name)};
	    $self->print_line('Continuing from last processed realm');
	} else {
	    $self->print_line('Starting from first realm');
	}
    }
    return $last_realm;
}

1;
