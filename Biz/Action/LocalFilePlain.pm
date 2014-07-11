# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::LocalFilePlain;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MAX_AGE) = 3600;
my($_TAGGED_MAX_AGE) = 60 * 60 * 24 * 365;
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
    my($tagged) = 0;
    if (Type_CacheTagFilePath()->is_tagged_path($file_name)) {
	$file_name = Type_CacheTagFilePath()->to_untagged_path($file_name);
	$tagged = 1;
    }
    else {
	_trace($file_name, ': missing cache tag') if $_TRACE;
    }
    my($mime_type);
    $proto->set_cacheable_output(
	_open($req, $file_name, \$mime_type),
	defined($content_type) ? $content_type : $mime_type,
	$req,
	$tagged,
    );
    return 1;
}

sub execute_apple_touch_icon {
    my($proto, $req) = @_;
    my($file_name) = $_FCT->get_value('apple_touch_icon_prefix', $req);
    b_die('invalid apple touch uri: ', $req->get('uri'))
	unless $req->get('uri') =~ m,/apple-touch-icon(.*?\.png)$,;
    my($suffix) = $1;
    my($res);
    my($die) = Bivio::Die->catch_quietly(
	sub {
	    $res = $proto->execute($req, $file_name . $suffix);
	},
    );
    if ($die) {
	# avoid warning in logs
	return 'DEFAULT_ERROR_REDIRECT_NOT_FOUND'
	    if $die->unsafe_get('code') && $die->get('code')->eq_not_found;
	$die->throw;
    }
    return $res;
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
    my(undef, $output, $mime_type, $req, $never_expire) = @_;
    return $req->get('reply')
	->set_output($output)
	->set_output_type($mime_type)
	->set_cache_max_age(
	    $never_expire ? $_TAGGED_MAX_AGE : $_MAX_AGE,
	    $req,
	    $never_expire,
	);
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
