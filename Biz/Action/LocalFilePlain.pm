# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::LocalFilePlain;
use strict;
$Bivio::Biz::Action::LocalFilePlain::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::LocalFilePlain::VERSION;

=head1 NAME

Bivio::Biz::Action::LocalFilePlain - retrieve documents from http root

=head1 SYNOPSIS

    use Bivio::Biz::Action::LocalFilePlain;

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::LocalFilePlain::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::LocalFilePlain> opens files in the C<Facade> local plain
files area. The file named by C<Request.uri> is returned with no
interpretation.

Uses L<Bivio::MIME::Type|Bivio::MIME::Type> to determine the mime type
of the file.

Doesn't allow the opening of files which begin with C<.> (dot-files) or which
are named C<CVS>.

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

=head2 execute(Bivio::Agent::Request req) : boolean

Reply with the document if it satisfies certain conditions.
If the URI is '/' or '', then reply with the home_page.

=cut

sub execute {
    my(undef, $req) = @_;
    my($mime_type);
    my($uri) = $req->get('uri');

    my($res) = _open($req, $uri, \$mime_type);
    my($reply) = $req->get('reply');
    $reply->set_output_type($mime_type);
    $reply->set_output($res);
    _trace(sprintf('total=%.3fs; db=%.3fs',
	    $req->get_current->elapsed_time,
	    Bivio::SQL::Connection->get_db_time)) if $_TRACE;
    return 1;
}

#=PRIVATE METHODS

# _open(Bivio::Agent::Request req, string_ref mime_type) : file_handle
#
# Opens the uri on the request as a document or throws NOT_FOUND
#
sub _open {
    my($req, $uri, $mime_type) = @_;
    my($doc) = Bivio::UI::Facade->get_local_file_name(
	    Bivio::UI::LocalFileType->PLAIN, $uri, $req);
    # No files which begin with '.' or contain CVS are allowed
    if ($doc =~ /\/\./ || $doc =~ /\/CVS/) {
	_trace($doc, ': invalid name') if $_TRACE;
    }
    else {
	# Ordinary file(?)
	$$mime_type = Bivio::MIME::Type->from_extension($doc);
	# Use only one handle to avoid leaks
	my($fh) = \*Bivio::Biz::Action::LocalFilePlain::IN;
	if (CORE::open($fh, '< '.$doc)) {
	    _trace($doc, ': opened') if $_TRACE;
	    return $fh;
	}
	_trace('open(', $doc, "): $!") if $_TRACE;
    }
    $req->throw_die('NOT_FOUND', {entity => $doc});
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
