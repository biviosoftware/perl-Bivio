# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$p
package Bivio::Biz::Action::DAV;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::IO::Trace;
use Bivio::Biz::Model;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
our($_TRACE);
my($_DIE) = {
    ALREADY_EXISTS => 'HTTP_PRECONDITION_FAILED',
#
    DIE => 'FORBIDDEN',
    IO_ERROR => 'FORBIDDEN',
    FORBIDDEN => 'FORBIDDEN',
    NOT_FOUND => 'NOT_FOUND',
    MODEL_NOT_FOUND => 'NOT_FOUND',
    CORRUPT_QUERY => 'BAD_REQUEST',
    CORRUPT_FORM =>  'BAD_REQUEST',
    NO_RESOURCES => 'HTTP_REQUEST_ENTITY_TOO_LARGE',
    INPUT_TOO_LARGE => 'HTTP_REQUEST_ENTITY_TOO_LARGE',
    DB_CONSTRAINT => 'HTTP_CONFLICT',
    UPDATE_COLLISION => 'HTTP_CONFLICT',
};
# This list should be complete, even though we don't implement them all
# NOTE: copy is not a write operation.  It's write on Destination, not source
my($_WRITABLE) = qr/^(delete|edit|lock|mkcol|move|put|proppatch|save|unlock)$/i;

sub execute {
    my($proto, $req) = @_;
    my($s) = {
	req => $req,
	r => $req->get('r'),
	method => lc($req->get('r')->method),
	uri => $req->get('uri'),
	path_info => $req->get('path_info'),
    };
    my($die) = Bivio::Die->catch(sub {
        return unless $s->{list} = _load(
	    $s, $req->get('auth_realm'), $req->get('path_info'));
	$s->{content} = $req->get_content;
	_trace($s->{method}, ' ', $s->{uri}, ' ',
	    {$s->{r}->headers_in}, "\n", $s->{content}
	) if $_TRACE;
	my($op) = \&{'_dav_' . $s->{method}};
	return _other_op($s)
	    unless defined(&$op);
        return if _precondition($s);
	return $op->($s);
    });
    if ($die) {
	my($n) = $die->get('code')->get_name;
	if ($n eq 'SERVER_REDIRECT_TASK') {
	    my($x) = $die->unsafe_get('attrs');
	    $x &&= $x->{task_id};
	    $x &&= $proto->is_blessed($x, 'Bivio::Agent::TaskId')
		&& $x->get_name;
	    $n = $x
		if ($x ||= '') =~ s/^DEFAULT_ERROR_REDIRECT_//;
	}
	_output($s, ($_DIE->{$n} || 'SERVER_ERROR'));
    }
    return 1
}

sub _call {
    my($s) = shift;
    my($method, $list) = (shift, $s->{list});
    if (ref($method)) {
	$list = $method;
	$method = shift;
    }
    $method = "dav_$method";
    _trace($list, "->$method", \@_) if $_TRACE;
    Bivio::Die->throw(FORBIDDEN => "$s->{method} not permitted on: $s->{uri}")
        unless $list->can($method);
    return $list->$method(@_);
}

sub _copy_move {
    my($s) = @_;
    my($d) = Bivio::HTML->unescape_uri($s->{r}->header_in('destination') || '');
    return _output($s, BAD_REQUEST => "cannot move across servers: $d")
	unless $d =~ s/^\Q@{[_fix_http($s, $s->{req}->format_http_prefix)]}//;
    return _output($s, HTTP_NOT_IMPLEMENTED => 'Depth 0 unsupported for COPY')
	if $s->{method} eq 'copy' && !_depth($s);
    my($t, $r, $path_info) = Bivio::UI::Task->parse_uri($d, $s->{req});
    return _output(
	$s, FORBIDDEN => "cannot $s->{method} across file system tasks"
    ) unless $t == $s->{req}->get('task_id');
    return 1
	unless $s->{dest_list} = _load($s, $r, $path_info, 1);
    return _output($s, FORBIDDEN => 'Destination is read-only: ', $path_info)
	if _call($s, $s->{dest_list}, 'is_read_only');
    return _output(
	$s, FORBIDDEN => "cannot $s->{method} across resource classes"
    ) unless $s->{dest_list}->isa(ref($s->{list}));
    return _output($s, HTTP_PRECONDITION_FAILED => 'Destination exists')
	if ($s->{dest_existed} = $s->{dest_list}->dav_exists)
	&& ($s->{r}->header_in('overwrite') || 'T') =~ /f/i;
    return;
}

sub _dav_copy {
    my($s) = @_;
    return 1
	if _copy_move($s);
    _call($s, copy => $s->{dest_list});
    return _output($s, $s->{dest_existed} ? 'HTTP_NO_CONTENT' : 'HTTP_CREATED');
}

sub _dav_delete {
    my($s) = @_;
    _call($s, 'delete')
	if $s->{exists};
    return _output($s, 'HTTP_OK');
}

sub _dav_edit {
    return _dav_get(@_);
}

sub _dav_get {
    my($s) = @_;
    return _call($s, 'reply_get')
	if $s->{list}->can('dav_reply_get');
    $s->{req}->get('reply')->set_last_modified(
	$s->{propfind}->{getlastmodified}
    ) if $s->{propfind}->{getlastmodified};
    return _output(
	$s, HTTP_OK => $s->{propfind}->{getcontenttype}, _call($s, 'get'));
}

sub _dav_head {
    return _dav_get(@_);
}

sub _dav_lock {
    my($s) = @_;
    my($owner) = grep($_,
	${$s->{content}} =~ /<owner>\s*([^<]+)\s*<|href>\s*([^<]+)\s*</s);
    my($want_href) = ${$s->{content}} =~ /href/;
    return _output(
	$s, HTTP_OK => qq{text/xml; charset="utf-8"}, \(
	join('',
	     qq{<?xml version="1.0" encoding="utf-8" ?>\n<D:prop xmlns:D="DAV:">\n},
	     _xml_render(
		 [lockdiscovery => [
		     [activelock => [
			 [locktype => [
			     ['write' => ''],
			 ]],
			 [lockscope => [
			     ['exclusive' => ''],
			 ]],
			 [depth => 'Infinity'],
			 $owner ? [owner => $want_href ? [[href => $owner]] : $owner]
			      : (),
			 [timeout => 'Second-1000000'],
			 [locktocken => [
			     [href => 'opaquelocktoken:' .
				 Bivio::Type::DateTime->now_as_file_name
				 . '-'
				 . int(rand(1_000_000_000))],
			 ]],
		     ]],
		 ]],
	     ),
	     "</D:prop>\n",
	 ),
    ));
}

sub _dav_mkcol {
    my($s) = @_;
    return _output($s, HTTP_CONFLICT => 'already exists')
	if $s->{exists};
    return _output($s, 'HTTP_UNSUPPORTED_MEDIA_TYPE')
	if length(${$s->{content}});
    _call($s, 'mkcol');
    return _output($s, 'HTTP_CREATED');
}

sub _dav_move {
    my($s) = @_;
    return 1
	if _copy_move($s);
    _call($s, move => $s->{dest_list});
    return _output($s, $s->{dest_existed} ? 'HTTP_NO_CONTENT' : 'HTTP_CREATED');
}

sub _dav_options {
    my($s) = @_;
    $s->{req}->get('reply')->set_header(
	Allow => join(
	    ', ',
	    map(uc($_),
		grep(
		    $_ ||
#TODO: always pretend everything works?

			!$s->{is_read_only} || $_ !~ $_WRITABLE,
		    qw(copy delete get head lock move options propfind unlock),
		    $s->{propfind}->{getcontenttype}
			? qw(edit put) : qw(mkcol),
		),
	    ),
	),
    );
    return _output($s, 'HTTP_OK', '', \(''));
}

sub _dav_propfind {
    my($s) = @_;
    my($noroot) = _depth($s) =~ /noroot/;
    return _output(
	$s, MULTI_STATUS => qq{text/xml; charset="utf-8"}, \(
	join('',
	     qq{<?xml version="1.0" encoding="utf-8" ?>\n<D:multistatus xmlns:D="DAV:">\n},
	     map({
		 my($x) = $_;
		 _xml_render(
		     [response => [
			 [href => _format_http($s, $x)],
			 [propstat => [
			     [prop => [
				 [displayname => $x->{displayname}],
				 $x->{getlastmodified}
				     ? [getlastmodified => $_DT->rfc822(
					 $x->{getlastmodified})]
				     : (),
				 $x->{getcontenttype} ? (
				     [getcontenttype => $x->{getcontenttype}],
				     [resourcetype => ''],
				     defined($x->{getcontentlength})
					 ? [getcontentlength =>
						$x->{getcontentlength}]
				         : (),
				 ) : (
				     [resourcetype => [
					 [collection => ''],
				     ]],
				 ),
			     ]],
			     [status => 'HTTP/1.1 200 OK'],
			 ]],
		     ]],
		 );
	     }
		 # Don't return dot files, e.g. '.DS_Store'
		 grep($_->{displayname} !~ m{^\.},
		      # Microsoft requires list to be sorted; RFC2518 doesn't
		      sort {lc($a->{displayname}) cmp lc($b->{displayname})}
		      @{_call($s, 'propfind_children')}
		 ),
		 # Microsoft seems to require this to be last
		 ($noroot ? () : $s->{propfind}),
	     ),
	     "</D:multistatus>\n",
	 ),
    ));
}

sub _dav_put {
    my($s) = @_;
    _call($s, put => $s->{content});
    return _output($s, HTTP_OK => "PUT $s->{uri}");
}

sub _dav_unlock {
    return _output(shift(@_), HTTP_OK => 'Unlocked');
}

sub _depth {
    my($s) = @_;
    my($x) = $s->{r}->header_in('depth');
    return defined($x) && length($x) ? $x : 'infinity';
}

sub _fix_http {
    my($s, $v) = @_;
    # Must match what the user asked for exactly
    $v =~ s{^https?://[^/]+}{@{[$s->{req}->format_http_prefix]}}
	|| Bivio::Die->throw_die(DIE => $v);
    return $v;
}

sub _format_http {
    my($s, $x) = @_;
    my($res) = $s->{req}->format_http({
	task_id => $s->{req}->get('task_id'),
	query => undef,
	path_info => "$s->{path_info}/$x->{uri}",
    });
    $res .= '/'
	unless $res =~ m{/$} || $x->{getcontenttype};
    return _fix_http($s, $res);
}

sub _has_write_permission {
    my($realm, $task, $req) = @_;
    return $realm->does_user_have_permissions(
	${Bivio::Auth::PermissionSet->from_array(
	    [map(Bivio::Auth::Permission->$_(),
		 grep(s/_READ$/_WRITE/,
		      map($_->get_name,
			  @{Bivio::Auth::PermissionSet->to_array(
			      $task->get('permission_set'))})))])},
	$req,
    );
}

sub _load {
    my($s, $realm, $path, $is_dest) = @_;
    my($req) = $s->{req};
    my($prev) = {map(($_ => $req->get($_)), qw(auth_realm task_id task))};
    $req->set_realm($realm);
    my($tid) = $req->get('task')->get_attr_as_id('next');
    $req->put(path_info => defined($path) ? $path : '');
    while ($tid) {
	_trace($tid, ' ', $req) if $_TRACE;
#TODO: Does not work with new Task->execute_items which return HASH
	my($t) = Bivio::Agent::Task->get_by_id($tid);
#TODO: It's not clear if this is over-restrictive.  However, 
	last unless $req->get('auth_realm')->can_user_execute_task($t, $req);
	$req->put(task_id => $tid, task => $t);
	if ($t->unsafe_get('require_dav')
	    || grep(($_->[0] || '') =~ /DAV/, @{$t->get('items')})) {
	    $tid = $req->get('task')->execute_items($req);
	    $tid &&= $tid->get('task_id');
	    next;
	}
	Bivio::Biz::Model->get_instance('AnyTaskDAVList')->execute($req);
	$tid = undef;
	last;
    }
    my($task) = $req->get('task');
    $realm = $req->get('auth_realm');
    $req->set_realm($prev->{auth_realm});
    $req->put(map(($_ => $prev->{$_}), qw(task_id task)));
    if ($tid) {
	_output($s, FORBIDDEN => 'No write access');
	return;
    }
    my($m) = $req->unsafe_get('dav_model');
    unless ($m) {
	_output($s, NOT_FOUND => 'No such resource: ', $path);
	return;
    }
#TODO: This is the wrong place to test security, but it works.
#      The problem is that the task has already executed, and we're rolling
#      back the transaction.  It's unlikely the user will get here so it's
#      probably ok, but we should review this at some point.
    if (($is_dest || $s->{method} =~ $_WRITABLE)
	&& !_has_write_permission($realm, $task, $req)
    ) {
	_output($s, FORBIDDEN => 'No write access');
	return;
    }
    return $m;
}

sub _other_op {
    my($s) = @_;
    return _output(
	$s, (HTTP_NOT_IMPLEMENTED => 'does not support: ' . $s->{method}));
}

sub _output {
    my($s, $status, $msg_or_type, $buf) = @_;
    my($n) = Bivio::Ext::ApacheConstants->$status();
    Bivio::IO::Alert->warn(
	$status, ' ', $s->{method}, ' ', $s->{uri}, ' ', $msg_or_type,
    ) if $status =~ /HTTP_PRECONDITION_FAILED|BAD_REQUEST|HTTP_NOT_IMPLEMENTED|HTTP_NOT_MODIFIED|HTTP_REQUEST_ENTITY_TOO_LARGE|FORBIDDEN|HTTP_CONFLICT/;
    $status =~ s/_/-/g;
    $s->{req}->get('reply')->set_http_status($n)
	->set_output_type(
	    ref($buf) && $msg_or_type ? $msg_or_type : 'text/plain'
	)->set_header(DAV => 2)
	->set_header('MS-Author-Via' => 'DAV')
        ->set_output(
	    ref($buf) ? $buf
		: \("$n $status" . ($msg_or_type ? " $msg_or_type\n" : "\n")));
    return 1;
}

sub _precondition {
    my($s) = @_;
    $s->{is_read_only} = _call($s, 'is_read_only');
    return _output($s, FORBIDDEN => 'Write operations not permitted')
	if $s->{is_read_only} && $s->{method} =~ $_WRITABLE;
    $s->{exists} = $s->{list}->dav_exists;
    $s->{list}->set_cursor(0)
	if $s->{exists};
    foreach my $x (
	['if-non-match' => sub {
	     return shift(@_)
		 && _output($s, HTTP_PRECONDITION_FAILED => 'Resource exists');
	}],
	['if-match' => sub {
	     return shift(@_)
		 || _output(
		     $s, HTTP_PRECONDITION_FAILED => 'Resource does not exist');
	}],
	['if-unmodified-since' => sub {
	     my($modified, $since) = @_;
	     return shift(@_) > 1
		 && _output($s, HTTP_PRECONDITION_FAILED => 'Modified since');
	}],
	['if-modified-since' => sub {
	     my($modified, $since) = @_;
	     return shift(@_) <= 0
		 && _output($s, HTTP_NOT_MODIFIED => 'Not modified since');
	}],
    ) {
	my($h, $op) = @$x;
	next unless my $v = $s->{r}->header_in($h);
	if ($h =~ /match/) {
	    return 1
		if $op->($s->{exists})
	}
	else {
	    my($t) = $_DT->from_literal($v);
	    return _output($s, BAD_REQUEST => "Invalid time: $h: $v")
		unless $t;
	    return 1
		if $s->{exists} && $op->(
		    $_DT->compare(
			$s->{list}->get('getlastmodified'), $t));
	}
    }
    if ($s->{exists}) {
	$s->{propfind} = _call($s, 'propfind');
	if (!$s->{propfind}->{getcontenttype}
		&& $s->{method} =~ /^(edit|get|head|put|save)$/) {
	    return _output($s, FORBIDDEN => "Resource is a directory: $s->{uri}");
#TODO: Something needed here for EditDAVList
#		unless $s->{method} eq 'head';
#	    $s->{method} = 'propfind';
	}
    }
    elsif ($s->{method} =~ /^(copy|delete|edit|get|head|lock|move|options|propfind|unlock)$/) {
	return _output($s, NOT_FOUND => "Resource does not exist: $s->{uri}");
    }
    return;
}

sub _xml_render {
    return map({
	my($t, $v) = @$_;
	defined($v) && length($v)
	   ? (
	       "<D:$t>",
	       ref($v) ? ("\n", _xml_render(@$v)) : Bivio::HTML->escape($v),
	       "</D:$t>\n"
	   ) : "<D:$t/>\n";
    } @_);
}

1;
