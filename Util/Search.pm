# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-search [options] command [args..]
commands
  rebuild_db -- reload entire search database
EOF
}

sub rebuild_db {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->are_you_sure('Destroy the ENTIRE Xapian database?');
    my($i) = 0;
    Bivio::Biz::Model->new($req, 'RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    if (0 == $i++ % 100) {
		# Executes first time through
		$self->commit_or_rollback;
		Bivio::IO::Alert->reset_warn_counter;
		$it->new_other('Lock')->execute_general($req);
		$self->use('Bivio::Search::Xapian')->destroy_db($req)
		    if $i == 1;
		Bivio::IO::Alert->info(
		    'file#', $i, ': ', $it->get('realm_file_id'));
	    }
	    Bivio::Search::Xapian->update_realm_file($it);
	    return 1;
        },
	'unauth_iterate_start',
	'realm_file_id asc',
	{is_folder => 0},
    );
    return;
}

1;
