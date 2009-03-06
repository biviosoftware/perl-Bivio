# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TaskLog;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: b HTTPStats [options] command [args..]
commands
    import_access_log -- import access_log data from STDIN
EOF
}

sub import_access_log {
    my($self) = @_;
    $self->initialize_ui;
    my($count) = 0;

    foreach my $line (split("\n", ${$self->read_input})) {
	my($user, $date, $method, $uri, $response_code) =
	    $line =~ /^\S+ [\d\.]+ \d+ \- (\S+) \[(.*?)\] \"(\w+) (\S+) .*?" (\d+)/;
	next unless $response_code && $response_code =~ /200|302/;
	my(undef, $su_id, $u_id) = $user =~ /^(su-(\d+)-)?li-(\d+)$/;
	my($task_id, $auth_realm) = b_use('Bivio::UI::Task')
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
	    uri => $uri,
	});
	$count++;
    }
    return "imported $count records\n";
}

sub _parse_date {
    my($date) = @_;
    my($mday, $mon, $year, $hour, $min, $sec) = split("/|:| ", $date);
    return $_DT->from_local_literal(
	$_DT->from_parts_or_die($sec, $min, $hour, $mday,
	    $_DT->english_month3_to_int($mon), $year));
}

1;
