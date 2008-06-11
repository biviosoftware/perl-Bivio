# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::LocalFilePlain;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
# Avoids a warning
my($_T) = __PACKAGE__->use('MIME.Type');

sub execute {
    # (self, Agent.Request, string, string) : boolean
    # Reply with the document found in the plain files area.
    #
    # If I<file_name> is not supplied, I<Request.uri> will be used.
    #
    # If I<content_type> is not supplied, it will be determined from I<file_name>.
    #
    # Always returns true (stop processing).
    my(undef, $req, $file_name, $content_type) = @_;
    my($mime_type);
    $file_name = $req->get('uri') unless defined($file_name);

    my($res) = _open($req, $file_name, \$mime_type);
    my($reply) = $req->get('reply');
    $reply->set_output_type(
	    defined($content_type) ? $content_type : $mime_type);
    $reply->set_output($res);
    _trace(sprintf('total=%.3fs; db=%.3fs',
	    $req->get_current->elapsed_time,
	    Bivio::SQL::Connection->get_db_time)) if $_TRACE;
    return 1;
}

sub execute_favicon {
    # (proto, Agent.Request) : boolean
    # Returns the file pointed to by I<Bivio::UI::Text.favicon_uri>.
    my($proto, $req) = @_;
    return $proto->execute(
	$req, Bivio::UI::Text->get_value('favicon_uri', $req));
}

sub execute_robots_txt {
    # (proto, Agent.Request) : boolean
    # Allow robot browsing only for production sites.
    my($proto, $req) = @_;
    my($disallow) = $req->get('is_production') ? '' : ' /';
    $req->get('reply')->set_output_type('text/plain');
    $req->get('reply')->set_output(\(<<"EOF"));
User-agent: *
Disallow:$disallow
EOF
    return 1;
}

sub execute_uri_as_view {
    # (proto, Agent.Request) : boolean
    # Uses I<Request.uri> as the view name and executes it.  May compile the
    # view dynamically.  The I<Request.uri> is prefixed with
    # I<Text.view_execute_uri_as_view_prefix>.
    #
    # Dies with NOT_FOUND, if uri is not found as uri.
    my($proto, $req) = @_;
    return $proto->use('Bivio::UI::View')->execute(
	Bivio::UI::Text->get_value('view_execute_uri_prefix', $req)
        . '/'
	. $req->get('uri'),
	$req);
}

sub _open {
    # (Agent.Request, string, string_ref) : file_handle
    # Opens the file_name on the request as a document or throws NOT_FOUND
    my($req, $file_name, $mime_type) = @_;
    my($doc) = Bivio::UI::Facade->get_local_file_name(
	    Bivio::UI::LocalFileType->PLAIN, $file_name, $req);
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
