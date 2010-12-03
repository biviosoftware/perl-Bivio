# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_X) = b_use('Search.Xapian');
my($_D) = b_use('Type.Date');
my($_RT) = b_use('Auth.RealmType');
my($_A) = b_use('IO.Alert');

sub USAGE {
    return <<'EOF';
usage: b-search [options] command [args..]
commands
  rebuild_db [after_date] -- reload entire search database, optionally files modified after date
  rebuild_realm [after_date] -- reindex all files in the current realm, optionally files modified after date
EOF
}

sub rebuild_db {
    sub REBUILD_DB {[[qw(?after_date Date)]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->are_you_sure('Rebuild Xapian database?');
    my($req) = $self->req;
    $_X->acquire_lock($req);
    $_X->destroy_db($req);
    my($realms) = $self->model('RealmFile')->map_iterate(
	sub {shift->get('realm_id')},
	'unauth_iterate_start',
	'realm_id',
	{path => '/'},
    );
    $self->commit_or_rollback;
    b_info('Rebuilding ', scalar(@$realms), ' realms');
    foreach my $r (@$realms) {
	next
	    if $_RT->is_default_id($r);
	$req->with_realm(
	    $r,
	    sub {
		b_info($self->rebuild_realm($bp->{after_date}));
		return;
	    },
	);
    }
    return;
}

sub rebuild_realm {
    sub REBUILD_REALM {[[qw(?after_date Date)]]}
    my($self, $bp) = shift->parameters(\@_);
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
    $self->model('RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    if (0 == $i++ % 100) {
		$commit->();
		$_X->acquire_lock($req);
		b_info(
		    'file#', $i, ': ', $it->get('realm_file_id'),
		) if $i > 1;
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
	'realm_file_id asc',
	{is_folder => 0},
    );
    $commit->();
    return $self->req(qw(auth_realm owner name)) . ": $j files";
}

1;
