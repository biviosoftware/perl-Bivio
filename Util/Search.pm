# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Search;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_X) = __PACKAGE__->use('Search.Xapian');

sub USAGE {
    return <<'EOF';
usage: b-search [options] command [args..]
commands
  module_version -- list versions of Xapian C++ and Perl XS libraries in use
  rebuild_db -- reload entire search database
  rebuild_realm -- reindex the current realm (does not delete index)
EOF
}

sub module_version {
    return 'Xapian C++ core v' . $_X->module_version()
	. "\nSearch::Xapian Perl XS v" .  $Search::Xapian::VERSION;
}

sub rebuild_db {
    my($self) = @_;
    $self->are_you_sure('Rebuild Xapian database?');
    $self->model('Lock')->acquire_general;
    my($realms) = $self->model('RealmFile')->map_iterate(
	sub {shift->get('realm_id')},
	'unauth_iterate_start',
	'realm_id',
	{path => '/'},
    );
    $self->commit_or_rollback;
    foreach my $r (@$realms) {
	system(
	    $^X,
	    '-w',
	    $0,
	    '-realm',
	    $r,
	    'rebuild_realm',
	);
    }
    return;
}

sub rebuild_realm {
    my($self) = @_;
    $self->usage_error('realm must be specified')
	unless $self->unsafe_get('realm');
    my($req) = $self->initialize_fully;
    my($i) = 0;
    b_info($self->req(qw(auth_realm owner name)));
    $self->model('RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    if (0 == $i++ % 100) {
		$self->commit_or_rollback;
		Bivio::IO::Alert->reset_warn_counter;
		$it->new_other('Lock')->acquire_general;
		b_info(
		    'file#', $i, ': ', $it->get('realm_file_id'),
		) if $i > 1;
	    }
	    $_X->update_model($req, $it);
	    return 1;
        },
	'realm_file_id asc',
	{is_folder => 0},
    );
    return;
}

1;
