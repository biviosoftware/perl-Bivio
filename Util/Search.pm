# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_X) = b_use('Search.Xapian');
my($_D) = b_use('Type.Date');
my($_RT) = b_use('Auth.RealmType');

sub USAGE {
    return <<'EOF';
usage: b-search [options] command [args..]
commands
  rebuild_db [date] -- reload entire search database, optionally files modified after date
  rebuild_realm [date] -- reindex all files in the current realm, optionally files modified after date
EOF
}

sub rebuild_db {
    my($self, $d) = @_;
    $self->are_you_sure('Rebuild Xapian database?');
    $_X->acquire_lock($self->req);
    $_X->destroy_db($self->req);
    my($realms) = $self->model('RealmFile')->map_iterate(
	sub {shift->get('realm_id')},
	'unauth_iterate_start',
	'realm_id',
	{path => '/'},
    );
    $self->commit_or_rollback;
    foreach my $r (@$realms) {
	next
	    if $_RT->is_default_id($r);
	system(
	    'bivio',
	    $self->package_name,
	    '-realm',
	    $r,
	    'rebuild_realm',
	    $d ? $d : ()
	);
    }
    return;
}

sub rebuild_realm {
    my($self, $date) = @_;
    $self->usage_error('realm must be specified')
	unless $self->unsafe_get('realm');
    my($req) = $self->initialize_fully;
    $date = $_D->from_literal_or_die($date)
	if $date;
    my($i) = 0;
    my($j) = 0;
    b_info('Re-indexing ' . $self->req(qw(auth_realm owner name)));
    $self->model('RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    if (0 == $i++ % 100) {
		$self->commit_or_rollback;
		Bivio::IO::Alert->reset_warn_counter;
		$_X->acquire_lock($req);
		b_info(
		    'file#', $i, ': ', $it->get('realm_file_id'),
		) if $i > 1;
	    }
	    return 1
		if $date && $_D->compare_defined(
		    $date, $it->get('modified_date_time')) > -1;
	    $_X->update_model($req, $it);
	    $j++;
	    return 1;
        },
	'realm_file_id asc',
	{is_folder => 0},
    );
    my($r) = $i ? ($date ? "Re-indexed $j "
		       . $self->req(qw(auth_realm owner name))
			   . ' files modified after ' . $_D->to_string($date)
			       . " of $i total files"
				   : "Re-indexed all $i "
				       . $self->req(qw(auth_realm owner name))
					   . ' files')
	: 'No files to re-index';
    b_info($r);
    return $r;
}

1;
