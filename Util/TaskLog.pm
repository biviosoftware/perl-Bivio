# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TaskLog;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_T) = b_use('Type.Text');
my($_TI) = b_use('Agent.TaskId');

sub USAGE {
    my($proto) = @_;
    return <<"EOF";
usage: bivio @{[$proto->simple_package_name]} [options] command [args..]
commands
    clear_missing_task_ids -- removes TaskLog entries for invalid TaskIds
    import_access_log -- import access_log data from STDIN
    test_reset -- remove all entries [test only]
EOF
}

sub clear_missing_task_ids {
    my($self) = @_;
    b_use('SQL.Connection')->do_execute(
	sub {
	    my($row) = @_;
	    return 1
		if $_TI->unsafe_from_int($row->[0]);
	    print('removing missing task id: ', $row->[0], "\n");
	    b_use('SQL.Connection')->execute(
		'DELETE FROM task_log_t WHERE task_id = ?',
		[$row->[0]]);
	    return 1;
	},
	'SELECT DISTINCT task_id FROM task_log_t'
    );
#TODO: not sure why this needs to be here, commit is missing otherwise
    b_use('SQL.Connection')->commit
	unless $self->unsafe_get('noexecute');
    return;
}

sub import_access_log {
    my($self) = @_;
    $self->initialize_ui;
    my($count) = 0;

    foreach my $line (split("\n", ${$self->read_input})) {
	my($user, $date, $method, $uri, $response_code) =
	    $line =~ /^\S+ [\d\.]+ \d+ \- (\S+) \[(.*?)\] \"(\w+) (\S+) .*?" (\d+)/;
	next unless $response_code && $response_code =~ /^[23]\d+$/s;
	my(undef, $su_id, $u_id) = $user =~ /^(su-(\d+)-)?li-(\d+)$/;
	my($task_id, $auth_realm) = b_use('FacadeComponent.Task')
	    ->parse_uri($uri, $self->req);
	$self->model('TaskLog')->create({
	    realm_id => $auth_realm->unsafe_get('owner')
	        ? $auth_realm->get('owner')->get('realm_id')
	        : $auth_realm->get('id'),
	    user_id => $u_id,
	    super_user_id => $su_id,
	    date_time => _parse_date($date),
	    task_id => $task_id,
	    method => $method,
	    uri => $_T->clean_and_trim($uri),
	});
	$count++;
    }
    return "imported $count records\n";
}

sub test_reset {
    my($self) = @_;
    $self->req->assert_test;
    $self->model('TaskLog')->test_unauth_delete_all;
    return;
}

sub _parse_date {
    my($date) = @_;
    my($mday, $mon, $year, $hour, $min, $sec) = split("/|:| ", $date);
    return $_DT->from_local_literal(
	$_DT->from_parts_or_die($sec, $min, $hour, $mday,
	    $_DT->english_month3_to_int($mon), $year));
}

1;
