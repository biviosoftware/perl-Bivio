# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Store::MIMEDecode;
use strict;
$Bivio::Mail::Store::MIMEDecode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

#TODO: try to be more descriptive
Bivio::Mail::Store::MIMEDecode - splits mail messages (Incoming)
into mime parts and stores each part to the file server.
Updates the mail_message_t database to indicate the number of
MIME parts, and also update club_t kbytes_in_use to keep track
of the amount of disk storage the club is using.

=head1 SYNOPSIS
    use Bivio::Mail::Store::MIMEDecode;
#TODO: Correct this to match the actual args
    Bivio::Mail::Store::MIMEDecode->new(
       Bivio::Mail::Incoming mail_incoming,
       string file_name,
       Bivio::File::Client file_client);

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Store::MIMEDecode::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::Store::MIMEDecode> is a simple MIME parsing engine.
It takes a L<Bivio::Mail::Incoming|Bivio::Mail::Incoming>
object, and recursively parses out the
MIME parts. Additionally, it creates a keyword hash of all
words found in all text/plain MIME parts.
Ultimately, it will also parse HTML parts.

=cut

#=IMPORTS
#TODO: btw, C-Xl sorts a region of lines.  I'd love to have
#      this section maintained magically, but it ain't in the cards right now.
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::MIMEType;
use Carp ();
use IO::Scalar;
use MIME::Parser;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_FILE_CLIENT);
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(
Bivio::Mail::Incoming mail_incoming,
string file_name,
Bivio::File::Client file_client) : Bivio::Mail::Store::MIMEDecode

mail_incoming : the mail message being sent to this club.
file_name : the name of the message (typically this is the message ID) pre-
pended with the path. i.e. '/clubname/messages/html'

=cut

sub new {
    my($proto, $mail_incoming, $file_name) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
        message => $mail_incoming,
	parser => MIME::Parser->new(output_to_core => 'ALL'),
	file_name => $file_name,
	kbytes => 0,
	num_parts => 0,
	#accumulates keywords parsed from text/plain message parts.
	keywords => {},
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_kbytes_written"></a>

=head2 get_kbytes_written() : int 

Returns the number of kilobytes written to the file server
for all MIME parts.


=cut

sub get_kbytes_written {
#TODO: I've started using the following style for this type of method
#      (retrieving a single attribute).  Paul and I discussed this and
#      we decided in this case it is clearer to avoid the @_ form.
    return shift->{$_PACKAGE}->{kbytes};
}

=for html <a name="get_num_parts"></a>

=head2 get_num_parts(void) : int

returns the number of MIME parts written to the file server.

=cut

sub get_num_parts {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{num_parts};
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item file_server : string (required)

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_FILE_CLIENT = Bivio::File::Client->new($cfg->{file_server});
    return;
}

=for html <a name="parse_and_store"></a>

=head2 parse_and_store()

Call this method to parse_and_store and store all MIME encoded parts.

=cut

sub parse_and_store {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($msg) = $fields->{message};
    Carp::croak('Mail incoming is undefined') unless $msg;
    my($file_name) = $fields->{file_name};
    my($keywords) = $fields->{keywords};

    #we know the first part is the main mail message. We want
    #to store keywords For Subject, To, Date, and From fields
    _parse_keywords($msg->get_subject(), $keywords);
    _parse_keywords($msg->get_reply_to(), $keywords);
    _parse_keywords($msg->get_dttm(), $keywords);
    # now extract all the MIME attachments
    _trace('extracting MIME attachments for mail message. File: ',
	    $file_name) if $_TRACE;
    # the second field is the file "extension". For the main message part,
    # this should be undef since there is no _0, _1, _0_1 suffix
#TODO: Simplify interface
    _extract_mime($fields->{parser}->read($msg->get_rfc822_io()),
	    $file_name, undef, $keywords, \$fields->{num_parts},
	    \$fields->{kbytes});
    _trace('getting all the keywords we found...') if $_TRACE;
#TODO: Personal preference alternative:
#    _trace('getting keywords') if $_TRACE;
#    "we found..." is unnecessary as it is obvious we found it.
    my($rslt);
    $_FILE_CLIENT->set_keywords($file_name, $keywords, \$rslt)
	    || die("set_keywords failed: \$rslt");
#TODO: The second trace is informative enough.
#    _trace('done with the keyword storage.') if $_TRACE;
    _trace('total bytes written (MIME): ', $fields->{kbytes}, ' K') if $_TRACE;
#TODO: Personal preference alternative:
#   _trace('wrote ', $fields->{kbytes}, 'KB and ', int(%$keywords)/2,
#          ' keywords') if $_TRACE;
#   My opinion on this is: the fully qualified method name contains MIME
#   and parse_and_store.  The extra text doesn't tell the reader much
#   more than what the method name indicates it is doing.
    return;
}

#=PRIVATE METHODS

#TODO: Every rule has an exception.  These are the "only" lines we
#      allow to be over 80 chars.  It is mostly important for "=head2"
#      lines of public methods.  So to be consistent...
#TODO: Syntax is "type name, type name".  Was missing name for MIME::Entity
#      Also was missing "int tnum_parts".
# _extract_mime(MIME::Entity entity, string file_name, string ext, hash_ref keywords, int tnum_parts, scalar_ref kbytes)
#
# Extracts sub mime parts for this mime entity. This method is called
# recursively. kbytes is incremented every time we write a MIME Entity to
# file storage. 
#
#TODO: Simplify interface as follows:
#   my($fields, $entity, $file_name) = @_;
#   $fields->{keywords}, $fields->{num_parts}, and $fields->{kbytes}
#   would be available.  $ext isn't necessary since the caller can do
#   the concatenation (see my note from 8/30).  This cuts the number
#   of parameters in half, thus reducing complexity by at least half.
#   Complexity increases as the number of params increases in a non-linear
#   fashion.  By halving the params, the decl becomes:
# _extract_mime(hash_ref fields, MIME::Entity entity, string file_name)
#   This fits in 80 chars, easily.  Greatly improving readability.
#   The coupling is still there, but it is through a "standard interface"
#   fields.  The reader says, "aha, the guy is using and possibly
#   modifying global state, because fields is passed in".  The reader
#   can then leave off what global state until s/he reads the implementation.
#   The caller must do more work, but it is clear what is going on
#   there as well:
#    _extract_mime($fields->{parser}->read($msg->get_rfc822_io()),
#	    $file_name, undef, $keywords, \$fields->{num_parts},
#	    \$fields->{kbytes});
#   becomes:
#    _extract_mime($fields, $fields->{parser}->read(
#      	    $msg->get_rfc822_io()), $file_name);
#   Note that the 'undef' goes away.  I can easily understand each of
#   these params without looking at method decl.  What's the "undef"?
#   Well, I'd need to go to the method decl to find out.
#   In the other calls, we have:
#	    _extract_mime($fields, $root_entity, $file_name.'_'.$i);
#   Again, it is clear that a suffix is being add to $file_name
#   AND the call is shortened to one line instead of two.
sub _extract_mime {
    my($entity, $file_name, $ext, $keywords, $tnum_parts, $kbytes) = @_;
    Carp::croak('no entity was passed to _extract_mime()') unless $entity;
    _trace('file_name: ', $file_name, ' ext: ', $ext) if $_TRACE;
    my($ctype) = lc($entity->head()->get('content-type'));
    my($content_type) = Bivio::Type::MIMEType->from_text($ctype);
    _trace(']]]]]]]]]]content type: ', $content_type) if $_TRACE;
    # parses keywords only if this is text/plain
    _parse_mime($entity, $keywords, $content_type);
#TODO: No need to pass in "$ext" separately.  Could just be $file_name
#      and which caller appends.  Simplifies interface and logic here.
    $file_name .= $ext || "";
    _trace('file_name after concat: ', $file_name) if $_TRACE;

#TODO parse for keyword storage if MIME part content type is HTML
#right now, we're only parsing for keywords MIME type "plain-text".

    _write_entity_to_file($entity, $file_name, $tnum_parts, $kbytes);

    my($num_parts) = $entity->parts || 0;
    my($i) = 0;
    _trace('number of parts for this MIME part is ', $num_parts) if $_TRACE;

    return unless $num_parts;

    for ($i = 0; $i < $num_parts; $i++){
	_trace('getting part ', $i) if $_TRACE;
	my($subentity) = $entity->part($i);
	my($head) = $subentity->head();
	my($ctype) = lc($head->get('content-type'));
#TODO: Extract the major/minor type, throwing away the clauses.  See
#      the RFC.  I don't know the rules on this, but we have to get the
#      parsing right.  This regexp is "sort of" right, but I don't know
#      the exact syntax rules.
#TODO: Use m!! (or whatever delim), because emacs cperl-mode gets confused
#      with \/.
	if ($ctype =~ m!^\s*message/rfc822\s*(?:\;|$)!) {
	    #special case processing for nested MIMEs.
#TODO We need to do the same thing for message/digest
	    _trace('the MIME part is an rfc922 message. Sub parsing this...')
		    if $_TRACE;
	    my($parser) = MIME::Parser->new(output_to_core => 'ALL');
	    my($sio) = $subentity->bodyhandle->open('r');
	    _trace('reading...') if $_TRACE;
            my($root_entity) = $parser->read($sio);

	    unless ($root_entity) {
		_trace('NO ROOT ENTITY WAS FOUND.') if $_TRACE;
		return;
	    }
	    _extract_mime($root_entity, $file_name, '_' . $i,
		    $keywords, $tnum_parts, $kbytes);
	}
	elsif ($ctype =~ m!^\s*text/plain\s*(?:\;|$)!) {
	    # then we want keywords from it
	    _trace('part is text/plain') if $_TRACE;
	    _extract_mime($subentity, $file_name, '_' . $i, $keywords,
		    $tnum_parts, $kbytes);
	}
    }
    return;
}

# _extract_mime_body_decoded(MIME::Entity entity) : scalar_ref
#
# Extracts the body of a MIME Entity decoded.
#
sub _extract_mime_body_decoded {
    my($entity) = @_;
    my($s);
#TODO: use single file handle to avoid leaks
    my $file = IO::Scalar->new(\$s);
    my($io) = $entity->open('r');
#TODO: Is this supposed to return an empty scalar?
    return \$s unless defined($io);
    my($line);
    $file->print($line) while defined($line = $io->getline);
    $io->close;
    return \$s
}

# _extract_mime_header(MIME::Entity entity) : string
#
# Extracts the MIME Header out of the entity. Returns it
# as a scalar.
sub _extract_mime_header {
    my($entity) = @_;
#TODO: use single file handle to avoid leaks
    _trace('>>printing mime header to IO::Scalar<<') if $_TRACE;
    my($s);
    $entity->head->print(IO::Scalar->new(\$s));
    _trace('done writing mime_header');
    return $s;
}

# _parse_keywords(string_ref str, hash_ref keywords)
#
# This method parses single line of text. It stores the
# individual words found in the hash_ref 'keywords' for
# later storage to the file server.
#
sub _parse_keywords {
    my($str, $keywords) = @_;

    # this is not necessarily an error:
    return unless $str;

#TODO: Don't want punctuation in keywords or contractions (Don't).
#      Algorithm probably need to take into account hyphenated words.
    my($w);
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;
}

# _parse_mime(MIME::Entity entity)
#
# Parses a MIME entity. If the MIME type is text/plain,
# then _parse_msg_line is called for each line of the content.
#
sub _parse_mime {
    my($entity, $keywords, $content_type) = @_;
    _trace('CONTENT_TYPE: ' , $content_type) if $_TRACE;
    if($content_type eq(Bivio::Type::MIMEType->TEXT_PLAIN)){
	_trace('content type TEXT_PLAIN. Parsing for keywords') if $_TRACE;
        my($file) = IO::Scalar->new(_extract_mime_body_decoded($entity));
	while (!$file->eof) {
	    my($line) = $file->getline();
	    _parse_msg_line($line, $keywords);
	}
	print(STDERR "done parsing\n");
    }
    return;
}

# _parse_msg_line(scalar line) : 
#
# Called for each line of a MIME part that is text/plain.
#
sub _parse_msg_line {
    my($str, $keywords) = @_;
    if($str eq('')){
	_trace('line is zero length. _parse_msg_line is ignorning it') if $_TRACE;
    }
#TODO: Handle multi-line tags.
    $str =~ s/--//g;
    $str = lc($str);
    $str =~ s/\&[a-z]//g;
    $str =~ s/\<.*\>//g;
    $str =~ s/[.]\s//g;
#TODO: Careful about stripping e-mail addrs.  Want to enter foo@bar.com as
#      a complete keyword.

    $str =~ s/[!#%^&*,();:\t\[\]]//g;
    # Strip leading spaces so split works nicely.
    $str =~ s/^\s+//;
    my($w);
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;
}

# _write_entity_to_file(
#    MIME::Entity entity,
#    string file_name, int_ref parts, scalar_ref kbytes)
#
# Writes the mime header and body content to a file.
#
sub _write_entity_to_file {
    my($entity, $file_name, $parts, $kbytes) = @_;
    #extract the header and body, and shove them into a string.
    #probably I should re-use a scalar ref or an IO handle for both of these.
    my($msg_hdr) = _extract_mime_header($entity);
    die('header is undef') unless defined($msg_hdr) && length($msg_hdr);
    my($msg_body) = _extract_mime_body_decoded($entity);
    _trace('no body in this MIME Entity')
	    if $_TRACE && !(defined($$msg_body) && length($$msg_body));
#TODO: Where is $msg_body being written?
    $msg_hdr .= "" unless $$msg_body;
    $$kbytes += length($msg_hdr)/1024;
    _trace('kbytes: ', $$kbytes) if $_TRACE;
    $_FILE_CLIENT->create($file_name, \$msg_hdr)
	    || die("write failed: $msg_hdr");
    $$parts++;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
