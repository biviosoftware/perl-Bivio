# Copyright (c) 2006-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_X) = b_use('Search.Xapian');
my($_D) = b_use('Type.Date');
my($_RT) = b_use('Auth.RealmType');
my($_A) = b_use('IO.Alert');
my($_CL) = b_use('IO.ClassLoader');

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

sub _map_classes {
    my($op) = @_;
    return [map(
	$op->(b_use('SearchParser', $_)),
	@{$_CL->list_simple_packages_in_map('SearchParser')},
    )];
}

1;
