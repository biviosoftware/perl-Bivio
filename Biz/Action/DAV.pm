# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::DAV;
use strict;
use base 'Bivio::Biz::Action::RealmFile';
use Bivio::Type::FileName;
use Bivio::IO::Trace;
use Bivio::Biz::Model;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
our($_TRACE);
my($_DIE) = {
    ALREADY_EXISTS => 'HTTP_CONFLICT',
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
my($_FP) = Bivio::Biz::Model->get_instance('RealmFile')->get_field_type('path');

sub execute {
    my($proto, $req) = @_;
    $req->set_user(
	Bivio::Biz::Model->new($req, 'RealmUser')->get_any_online_admin);
    my($s) = {
	proto => $proto,
	file => Bivio::Biz::Model->new($req, 'RealmFile'),
	req => $req,
	reply => $req->get('reply'),
	r => $req->get('r'),
	method => $req->get('r')->method,
    };
    my($p, $e) = $_FP->from_literal($req->get('path_info') || '/');
    return _output($s, BAD_REQUEST => 'Invalid resource name: ' . $req->get('path_info'))
	if $e;
    $s->{path} = $p;
    $s->{file}->unsafe_load(_file_args($s));
    my($op) = \&{'_dav_' . lc($s->{method})};
    return 1
	if _content($s);
    _trace(
	$s->{method},
	' ',
	$req->get('uri'),
	' ',
	{$s->{r}->headers_in}, "\n", \($s->{content}),
    ) if $_TRACE;
    return _other_op($s)
        unless defined(&$op);
    return 1
	if _precondition($s);
    my($die) = Bivio::Die->catch(sub {
	$op->($s);
    });
    return $die ? _output(
	$s, ($_DIE->{$die->get('code')->get_name} || 'SERVER_ERROR'))
	: 1;
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
    my($d) = $s->{r}->header_in('destination');
    return _output($s, BAD_REQUEST => "cannot move across servers: $d")
	unless $d =~ s/^\Q@{[_format_http($s)]}//;
    $s->{dest} = ($_FP->from_literal($d))[0];
    return _output($s, BAD_REQUEST => 'Invalid destination name')
	unless $s->{dest};
    return
	unless ($s->{dest_file} = $s->{file}->new)->unsafe_load({
	    %{_file_args($s)},
	    path => $s->{dest},
	});
    return _output($s, HTTP_PRECONDITION_FAILED => 'Destination exists')
	unless $s->{r}->header_in('overwrite');
    return _output($s, FORBIDDEN => 'Destination cannot be a directory')
	if $s->{dest_file}->get('is_folder');
    return;
}

sub _dav_delete {
    my($s) = @_;
    return if _is_not_empty($s);
    $s->{file}->delete;
    return _output($s, 'HTTP_OK');
}

sub _dav_edit {
    my($s) = @_;
    return _output($s, FORBIDDEN => 'is a directory')
	if $s->{file}->get('is_folder');
    return _output(
	$s, HTTP_OK => $s->{file}->get_content_type, $s->{file}->get_handle);
}

sub _dav_get {
    my($s) = @_;
    return _output(
	$s, HTTP_OK => $s->{file}->get_content_type, $s->{file}->get_handle);
}

sub _dav_mkcol {
    my($s) = @_;
    return _output($s, FORBIDDEN => 'already exists')
	if $s->{file}->is_loaded;
    return _output($s, 'HTTP_UNSUPPORTED_MEDIA_TYPE')
	if length($s->{content});
    $s->{file}->create_folder(_file_args($s));
    return _output($s, 'HTTP_CREATED');
}

sub _dav_move {
    my($s) = @_;
    return 1
	if _copy_move($s);
    $s->{dest_file}->delete
	if my $exists = $s->{dest_file}->is_loaded;
    $s->{file}->update({
	%{_file_args($s)},
	path => $s->{dest},
    });
    return _output($s, $exists ? 'HTTP_NO_CONTENT' : 'HTTP_CREATED');
}

sub _dav_options {
    my($s) = @_;
    $s->{reply}->set_header(
	Allow => join(
	    ', ',
	    qw(COPY DELETE GET HEAD LOCK MOVE OPTIONS POST PROPFIND UNLOCK),
	    $s->{file}->unsafe_get('is_folder')
		? qw(BROWSE INDEX MKCOL)
		: qw(EDIT PUT SAVE),
	),
    );
    return _output($s, 'HTTP_OK', '', \(''));
}

sub _dav_propfind {
    my($s) = @_;
    my($depth) = $s->{r}->header_in('depth') || 'infinity';
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
				 [displayname => Bivio::HTML->escape(
				     $x->{path} =~ m{([^/]+)$})],
				 # MS
				 [isroot => $x->{isroot} || '0'],
				 [getlastmodified => $_DT->rfc822(
				     $_DT->to_unix(
					 $x->{modified_date_time}))],
				 $x->{is_folder} ? (
				     [getcontenttype => 'text/html'],
				     [resourcetype => [
					 [collection => ''],
				     ]],
				 ) : (
				     [getcontenttype => $x->{type}],
				     [getcontentlength => $x->{length}],
				     [resourcetype => ''],
				 ),
			     ]],
			     [status => 'HTTP/1.1 200 OK'],
			 ]],
		     ]],
		 );
	     }
		 ($noroot ? () : {
		     %{$s->{file}->get_shallow_copy},
		     isroot => 1,
		 }),
		 $depth && $s->{file}->get('is_folder')
		     ? @{$s->{file}->map_folder(
			 sub {
			     my($f) = @_;
			     my($res) = $f->get_shallow_copy;
			     unless ($res->{is_folder}) {
				 $res->{length} = $f->get_content_length;
				 $res->{type} = $f->get_content_type;
			     }
			     return $res;
			  },
		     )}
		     : (),
	     ),
	     "</D:multistatus>\n",
	 ),
    ));
}

sub _dav_put {
    my($s) = @_;
    my($op) = ($s->{file}->is_loaded ? 'update' : 'create') . '_with_content';
    $s->{file}->$op(_file_args($s), \$s->{content});
    $op =~ s/_with_content/d/;
    return _output($s, HTTP_OK => "$op $s->{path}");
}

sub _file_args {
    my($s) = @_;
    return {
	volume => $s->{req}->get('Type.FileVolume'),
	path => $s->{path},
    };
}

sub _format_http {
    my($s, $x) = @_;
    $x = {
	path => '/',
	is_foler => 0,
    } unless $x;
    my($res) = $s->{req}->format_http({
	task_id => $s->{req}->get('task_id'),
	query => undef,
	path_info => $x->{path},
    }) . ($x->{is_folder} && $x->{path} !~ m{/$} ? '/' : '');
    # Must match what the user asked for exactly
    $res =~ s{^(https?://)[^/:]+}{$1@{[$s->{r}->hostname]}} || die;
    return $res;
}

sub _is_not_empty {
    my($s) = @_;
    return _output($s, FORBIDDEN => "Folder is not empty: $s->{path}")
	unless $s->{file}->is_empty;
    return;
}

sub _other_op {
    my($s) = @_;
    return _output(
	$s,
	$s->{method} =~ /^(LOCK|UNLOCK)$/
	    ? (HTTP_OK => '')
	    : (HTTP_NOT_IMPLEMENTED => 'does not support: ' . $s->{method}));
}

sub _output {
    my($s, $status, $msg_or_type, $buf) = @_;
    my($n) = Bivio::Ext::ApacheConstants->$status();
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
    my($exists) = $s->{file}->is_loaded;
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
		if $op->($exists)
	}
	else {
	    my($t) = $_DT->from_literal($v);
	    return _output($s, BAD_REQUEST => "Invalid time: $h: $v")
		unless $t;
	    return 1
		if $exists && $op->(
		    $_DT->compare($s->{file}->get('modified_date_time'), $t));
	}
    }
    return _output($s, NOT_FOUND => "Resource does not exist: $s->{path}")
	unless $exists || $s->{method} !~ /^(BROWSE|COPY|DELETE|EDIT|GET|HEAD|LOCK|MOVE|OPTIONS|PROPFIND|PROPPATCH|UNLOCK)$/i;
    return _output($s, FORBIDDEN => 'Cannot operate on rooot')
	if $s->{path} eq '/' && $s->{method} =~ /^(COPY|DELETE|EDIT|MOVE|PUT|SAVE)$/;
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
