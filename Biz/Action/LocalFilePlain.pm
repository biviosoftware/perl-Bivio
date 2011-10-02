# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::LocalFilePlain;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MAX_AGE) = 3600;
our($_TRACE);
b_use('IO.Trace');
my($_T) = b_use('MIME.Type');
my($_FCC) = b_use('FacadeComponent.Constant');
my($_IOC) = b_use('IO.Config');
my($_FCT) = b_use('FacadeComponent.Text');
my($_F) = b_use('UI.Facade');
my($_PLAIN) = b_use('UI.LocalFileType')->PLAIN;
my($_DT) = b_use('Type.DateTime');

sub execute {
    my($proto, $req, $file_name, $content_type) = @_;
    $file_name = $req->get('uri')
	unless defined($file_name);
    my($mime_type);
    $proto->set_cacheable_output(
	_open($req, $file_name, \$mime_type),
	defined($content_type) ? $content_type : $mime_type,
	$req,
    );
    return 1;
}

sub execute_favicon {
    my($proto, $req) = @_;
    return $proto->execute($req, $_FCT->get_value('favicon_uri', $req));
}

sub execute_robots_txt {
    my($proto, $req) = @_;
    my($disallow) = $req->get('is_production')
	&& $_FCC->get_value('robots_txt_allow_all', $req)
	? '' : ' /';
    $proto->set_cacheable_output(\(<<"EOF"), 'text/plain', $req);
User-agent: *
Disallow:$disallow
EOF
    return 1;
}

sub execute_uri_as_view {
    my($proto, $req) = @_;
    return b_use('UI.View')->execute(
	$_FCC->get_value('view_execute_uri_prefix', $req)
        . '/'
	. $req->get('uri'),
	$req);
}

sub set_cacheable_output {
    my(undef, $output, $mime_type, $req) = @_;
    my($reply) = $req->get('reply');
    $reply->set_output($output)
	->set_output_type($mime_type);
    $reply
	->set_header('Cache-Control', "max-age=$_MAX_AGE")
	->set_header(Expires => $_DT->rfc822($_DT->add_seconds($_DT->now, $_MAX_AGE)))
	if $_F->get_from_source($req)->get('want_local_file_cache');
    return $reply;
}

sub _open {
    # (Agent.Request, string, string_ref) : file_handle
    # Opens the file_name on the request as a document or throws NOT_FOUND
    my($req, $file_name, $mime_type) = @_;
    my($doc) = $_F->get_local_file_name($_PLAIN, $file_name, $req);
    # No files which begin with '.' or contain CVS are allowed
    if ($file_name =~ /\/\./ || $file_name =~ /\/CVS/) {
	_trace($doc, ': invalid name') if $_TRACE;
    }
    else {
	$$mime_type = $_T->from_extension($doc);
	if (my $fh = IO::File->new('< ' . $doc)) {
	    _trace($doc, ': opened') if $_TRACE;
	    $$mime_type = 'text/plain'
		if $$mime_type eq 'application/octet-stream'
		&& -T $doc;
	    return $fh;
	}
	_trace('open(', $doc, "): $!") if $_TRACE;
    }
    $req->throw_die('NOT_FOUND', {entity => $doc});
    # DOES NOT RETURN
}

1;
