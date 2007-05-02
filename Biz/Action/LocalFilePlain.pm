# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::LocalFilePlain;
use strict;
$Bivio::Biz::Action::LocalFilePlain::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::LocalFilePlain::VERSION;

=head1 NAME

Bivio::Biz::Action::LocalFilePlain - retrieve documents from http root

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::LocalFilePlain;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::LocalFilePlain::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::LocalFilePlain> opens files in the C<Facade> local plain
files area. The file named by C<Request.uri> is returned with no
interpretation unless L<execute|"execute"> is called explicitly in
which case both the file name and content type may be overriden.

Uses L<Bivio::MIME::Type|Bivio::MIME::Type> to determine the mime type
of the file.

Doesn't allow the opening of files which begin with C<.> (dot-files) or which
are named C<CVS>.

=head1 ATTRIBUTES

=over 4

=item Request.uri : string

Default file name.

=back

=cut

#=IMPORTS
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::MIME::Type;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
# Avoids a warning
$Bivio::Biz::Action::LocalFilePlain::IN = undef;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req, string file, string content_type) : boolean

Reply with the document found in the plain files area.

If I<file_name> is not supplied, I<Request.uri> will be used.

If I<content_type> is not supplied, it will be determined from I<file_name>.

Always returns true (stop processing).

=cut

sub execute {
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

=for html <a name="execute_favicon"></a>

=head2 static execute_favicon(Bivio::Agent::Request req) : boolean

Returns the file pointed to by I<Bivio::UI::Text.favicon_uri>.

=cut

sub execute_favicon {
    my($proto, $req) = @_;
    return $proto->execute(
	$req, Bivio::UI::Text->get_value('favicon_uri', $req));
}

=for html <a name="execute_robots_txt"></a>

=head2 static execute_robots_txt(Bivio::Agent::Request req) : boolean

Allow robot browsing only for production sites.

=cut

sub execute_robots_txt {
    my($proto, $req) = @_;
    my($disallow) = $req->get('is_production') ? '' : ' /';
    $req->get('reply')->set_output_type('text/plain');
    $req->get('reply')->set_output(\(<<"EOF"));
User-agent: *
Disallow:$disallow
EOF
    return 1;
}

=for html <a name="execute_uri_as_view"></a>

=head2 static execute_uri_as_view(Bivio::Agent::Request req) : boolean

Uses I<Request.uri> as the view name and executes it.  May compile the
view dynamically.  The I<Request.uri> is prefixed with
I<Text.view_execute_uri_as_view_prefix>.

Dies with NOT_FOUND, if uri is not found as uri.

=cut

sub execute_uri_as_view {
    my($proto, $req) = @_;
    return $proto->use('Bivio::UI::View')->execute(
	Bivio::UI::Text->get_value('view_execute_uri_prefix', $req)
        . '/'
	. $req->get('uri'),
	$req);
}

#=PRIVATE METHODS

# _open(Bivio::Agent::Request req, string file_name, string_ref mime_type) : file_handle
#
# Opens the file_name on the request as a document or throws NOT_FOUND
#
sub _open {
    my($req, $file_name, $mime_type) = @_;
    my($doc) = Bivio::UI::Facade->get_local_file_name(
	    Bivio::UI::LocalFileType->PLAIN, $file_name, $req);
    # No files which begin with '.' or contain CVS are allowed
    if ($file_name =~ /\/\./ || $file_name =~ /\/CVS/) {
	_trace($doc, ': invalid name') if $_TRACE;
    }
    else {
	# Ordinary file(?)
	$$mime_type = Bivio::MIME::Type->from_extension($doc);
	# Use only one handle to avoid leaks
	my($fh) = \*Bivio::Biz::Action::LocalFilePlain::IN;
	if (CORE::open($fh, '< '.$doc)) {
	    _trace($doc, ': opened') if $_TRACE;

	    # If the file type is unknown (octet-stream), but perl thinks
	    # it is text, we return it as text.
	    $$mime_type = 'text/plain'
		if $$mime_type eq 'application/octet-stream'
		&& -T $fh;
	    return $fh;
	}
	_trace('open(', $doc, "): $!") if $_TRACE;
    }
    $req->throw_die('NOT_FOUND', {entity => $doc});
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
