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
    DIE => 'FORBIDDEN',
    IO_ERROR => 'FORBIDDEN',
    FORBIDDEN => 'FORBIDDEN',
    NOT_FOUND => 'NOT_FOUND',
    MODEL_NOT_FOUND => 'NOT_FOUND',
    CORRUPT_QUERY => 'BAD_REQUEST',
    CORRUPT_FORM =>  'BAD_REQUEST',
    NO_RESOURCES => 'HTTP_REQUEST_ENTITY_TOO_LARGE',
    DB_CONSTRAINT => 'HTTP_CONFLICT',
    UPDATE_COLLISION => 'HTTP_CONFLICT',
};
# This list should be complete, even though we don't implement them all
my($_WRITABLE) = qr/^(copy|delete|edit|lock|mkcol|move|put|proppatch|save|unlock)$/;
sub execute {
    my(undef, $req) = @_;
    my($s) = {
	req => $req,
	reply => $req->get('reply'),
	r => $req->get('r'),
	method => lc($req->get('r')->method),
	uri => $req->get('uri'),
	path_info => $req->get('path_info'),
	root_model => $req->get_by_regexp(qr{Model\.\w+DAVList}),
    };
    my($die) = Bivio::Die->catch(sub {
        return unless $s->{list} = _load(
	    $s, $req->get('auth_realm'), $req->get('path_info'));
	my($op) = \&{'_dav_' . $s->{method}};
	return if _content($s);
	_trace($s->{method}, ' ', $s->{uri}, ' ',
	       {$s->{r}->headers_in}, "\n", \($s->{content})
	) if $_TRACE;
	return _other_op($s)
	    unless defined(&$op);
        return if _precondition($s);
	return $op->($s);
    });
    _output($s, ($_DIE->{$die->get('code')->get_name} || 'SERVER_ERROR'))
	if $die;
    return 1;
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

sub _content {
    my($s) = @_;
    $s->{content} = '';
    return unless my $l = $s->{r}->header_in('content-length');
    return _output(
	$s, HTTP_REQUEST_ENTITY_TOO_LARGE => "Content-Length too large: $l",
    #TODO: Make this dependent on a config parameter in request
    ) if $l > 100_000_000;
    $s->{r}->read($s->{content}, $l);
    return _output(
	$s, BAD_REQUEST => "Content-Length ($l) >= actual length: ",
	length($s->{content}),
    ) if $l > length($s->{content});
    return;
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
    return unless $s->{dest_list} = _load($s, $r, $path_info, 1);
    return _output(
	$s, FORBIDDEN => "cannot $s->{method} across file system classes"
    ) unless $s->{dest_list}->isa(ref($s->{list}));
    return _output($s, HTTP_PRECONDITION_FAILED => 'Destination exists')
	if ($s->{dest_existed} = _exists($s->{dest_list}))
	&& ($s->{r}->header_in('overwrite') || 'T') =~ /f/i;
    _call($s, $s->{dest_list}, 'delete')
	if $s->{dest_existed};
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
    $s->{reply}->set_last_modified($s->{propfind}->{getlastmodified})
	if $s->{propfind}->{getlastmodified};
    return _output(
	$s, HTTP_OK => $s->{propfind}->{getcontenttype}, _call($s, 'get'));
}

sub _dav_head {
    return _dav_get(@_);
}

sub _dav_lock {
    return _output(shift(@_), HTTP_OK => 'Locked');
}

sub _dav_mkcol {
    my($s) = @_;
    return _output($s, HTTP_CONFLICT => 'already exists')
	if $s->{exists};
    return _output($s, 'HTTP_UNSUPPORTED_MEDIA_TYPE')
	if length($s->{content});
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
    $s->{reply}->set_header(
	Allow => join(
	    ', ',
	    map(uc($_),
		grep(
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
    my($depth) = _depth($s);
    my($noroot) = $depth =~ s/\s*,\s*noroot//
	|| $s->{content} =~ /schemas-microsoft/;
    # We don't recurse
    $depth =~ s/infinity/1/;
    # Ignore stuff we don't understand
    $depth =~ s/\D//g;
    return _output(
	$s, MULTI_STATUS => qq{text/xml; charset="utf-8"}, \(
	join('',
	     qq{<?xml version="1.0"?>\n<D:multistatus xmlns:D="DAV:">\n},
	     map({
		 my($x) = $_;
		 _propfind_render(
		     [response => [
			 [href => _format_http($s, $x)],
			 [propstat => [
			     [prop => [
				 [displayname => Bivio::Type::String->to_xml(
				     $x->{displayname},
				 )],
				 $x->{getlastmodified}
				     ? [getlastmodified => $_DT->rfc822(
					 $x->{getlastmodified})]
				     : (),
				 $x->{getcontenttype} ? (
				     [getcontenttype => $x->{getcontenttype}],
				     [getcontentlength => $x->{getcontentlength}],
				     [resourcetype => ''],
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
	         ($noroot ? () : $s->{propfind}),
		 @{_call($s, 'propfind_children')},
	     ),
	     "</D:multistatus>\n",
	 ),
    ));
}

sub _dav_put {
    my($s) = @_;
    _call($s, put => \$s->{content});
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

sub _exists {
    return shift->get_result_set_size > 0 ? 1 : 0;
}

sub _fix_http {
    my($s, $v) = @_;
    # Must match what the user asked for exactly
    $v =~ s{^(https?://)[^/:]+}{$1@{[$s->{r}->hostname]}}
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

sub _load {
    my($s, $realm, $path, $is_dest) = @_;
    my($q) = {
	path => defined($path) ? $path : '',
	realm => $realm,
	model => $s->{root_model}->new,
    };
    my($m);
    while (1) {
	_trace($q) if $_TRACE;
	unless ($q->{realm}->does_user_have_permissions(
	    ${Bivio::Auth::PermissionSet->from_array(['DATA_READ'])},
	    $s->{req},
	)) {
	    _output($s, FORBIDDEN => 'User does not have access');
	    return;
	}
	$q->{is_read_only} = $q->{realm}->does_user_have_permissions(
	    ${Bivio::Auth::PermissionSet->from_array(['DATA_WRITE'])},
	    $s->{req},
	) ? 0 : 1;
	$m = $q->{model}->dav_load($q);
	last unless ref($m) eq 'HASH';
	$q = $m;
    }
    unless ($m) {
	_output($s, NOT_FOUND => 'No such resource: ', $path);
	return;
    }
    if ($q->{is_read_only} && $is_dest) {
	_output($s, FORBIDDEN => 'Destination is read-only');
	return;
    }
    $s->{is_read_only} = $q->{is_read_only};
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
    $s->{reply}->set_http_status($n)
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
    $s->{is_read_only} ||= _call($s, 'is_read_only');
    return _output($s, FORBIDDEN => 'Write operations not permitted')
	if $s->{is_read_only} && $s->{method} =~ $_WRITABLE;
    $s->{exists} = _exists($s->{list});
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
			$s->{list}->get_by_regexp('modified_date_time'), $t));
	}
    }
    if ($s->{exists}) {
	$s->{propfind} = _call($s, 'propfind');
	return _output($s, FORBIDDEN => "Resource is a directory: $s->{uri}")
	    if !$s->{propfind}->{getcontenttype}
		&& $s->{method} =~ /^(edit|get|head|put|save)$/;
    }
    elsif ($s->{method} =~ /^(copy|delete|edit|get|head|lock|move|options|propfind|unlock)$/) {
	return _output($s, NOT_FOUND => "Resource does not exist: $s->{uri}");
    }
    return;
}

sub _propfind_render {
    map({
	my($t, $v) = @$_;
	defined($v) && length($v)
	   ? (
	       "<D:$t>",
	       ref($v) ? ("\n", _propfind_render(@$v)) : $v,
	       "</D:$t>\n"
	   ) : "<D:$t/>\n";
    } @_);
}

1;
