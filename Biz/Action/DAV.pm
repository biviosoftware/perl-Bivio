# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::DAV;
use strict;
use base 'Bivio::Biz::Action::RealmFile';
use Bivio::Type::FileName;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
our($_TRACE);

sub execute {
    my($proto, $req) = @_;
    my($s) = {
	proto => $proto,
	file => Bivio::Biz::Model->new($req, 'RealmFile'),
	req => $req,
	reply => $req->get('reply'),
	r => $req->get('r'),
	method => $req->get('r')->method,
    };
    my($p, $e) = $s->{file}->get_field_type('path')
	->from_literal($req->get('path_info') || '/');
    return _output($s, BAD_REQUEST => 'Invalid resource name: ' . $req->get('path_info'))
	if $e;
    $s->{path} = $p;
    $s->{file}->unsafe_load({
	volume => $req->get('Type.FileVolume'),
	path => $s->{path},
#	is_public => 1,
    });
    my($op) = \&{'_dav_' . lc($s->{method})};
    my($l) = $s->{r}->header_in('content-length');
    return _output(
	$s, HTTP_REQUEST_ENTITY_TOO_LARGE => "Content-Length too large: $l",
#TODO: Make this dependent on a config parameter in request
    ) if $l > 100_000_000;
    $s->{r}->read($s->{content}, $l);
    return _output(
	$s, BAD_REQUEST => "Content-Length ($l) >= actual length: ",
	length($s->{content}),
    ) if $l > length($s->{content});
    _trace({$s->{r}->headers_in}, "\n", \($s->{content})) if $_TRACE;
    return _output(
	$s, HTTP_NOT_IMPLEMENTED => 'does not support: ' . $s->{method},
    ) unless defined(&$op);
    return 1
	if _precondition($s);
    return $op->($s);
}

sub _dav_options {
    my($s) = @_;
    $s->{reply}->map_invoke(set_header => [
# Must return both
# DAV: 1 2
	[DAV => 1],
	['MS-Author-Via' => 'DAV'],
	[Allow => join(
	    ', ',
	    qw(OPTIONS GET POST HEAD COPY PROPFIND),
	    $s->{file}->get('is_folder') ? qw(BROWSE INDEX) : qw(EDIT),
	)],
    ]);
    $s->{reply}->set_output(\(''));
    return _output($s, 'HTTP_OK');
}

sub _dav_propfind {
    my($s) = @_;
    my($depth) = $s->{r}->header_in('depth') || 'infinity';
    my($noroot) = $depth =~ s/\s*,\s*noroot//;
    # We don't recurse
    $depth =~ s/infinity/1/;
    # Ignore stuff we don't understand
    $depth =~ s/\D//g;
    $s->{reply}->set_output(\(
	join('',
	     qq{<?xml version="1.0"?>\n<D:multistatus xmlns:D="DAV:">\n},
	     map(
		 _propfind_render(
		     [response => [
			 [href => $s->{req}->format_http({
			     task_id => $s->{req}->get('task_id'),
			     query => undef,
			     path_info => $_->{path},
			 }) . (
			     $_->{is_folder} && $_->{path} !~ m{/$} ? '/' : ''
			 )],
			 [propstat => [
			     [prop => [
				 [displayname =>
				      ($_->{path} =~ m{([^/]+)$})[0]],
				 [getlastmodified => $_DT->rfc822(
				     $_DT->to_unix(
					 $_->{modified_date_time}))],
				 $_->{is_folder} ? (
				     [contenttype => 'text/html'],
				     [resourcetype => [
					 [collection => ''],
				     ]],
				 ) : (
				     [contenttype => $_->{type}],
				     [contentlength => $_->{length}],
				     [resourcetype => ''],
				 ),
			     ]],
			     [status => 'HTTP/1.1 200 OK'],
			 ]],
		     ]],
		 ),
		 ($noroot ? () : $s->{file}->get_shallow_copy),
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
    $s->{reply}->set_output_type(
	'Content-Type' => qq{text/xml; charset:"utf-8"});
    return _output($s, MULTI_STATUS => '');
}

sub _output {
    my($s, $status, $msg) = @_;
    my($n) = Bivio::Ext::ApacheConstants->$status();
    $s->{reply}->set_http_status($n);
    $s->{reply}->set_output_type('text/plain');
    substr($msg, 0, 0) = ' '
	if $msg;
    $status =~ s/_/-/g;
    $s->{reply}->set_output(\("$n $status" . ($msg ? " $msg\n" : "\n")))
	unless $n =~ /^2/;
    return 1;
}

sub _precondition {
    my($s) = @_;
    my($exists) = $s->{file}->is_loaded;
    return _output($s, NOT_FOUND => "Resource does not exist: $s->{path}")
	unless $exists || $s->{method} =~ /^MK|PUT/i;
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
		if $exists && $op->($s->{file}->get('modified_date_time'), $t);
	}
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
