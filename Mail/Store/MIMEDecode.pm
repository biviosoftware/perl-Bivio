# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Store::MIMEDecode;
use strict;
$Bivio::Mail::Store::MIMEDecode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Store::MIMEDecode - splits mail messages (Incoming)
into mime parts and stores each part to the file server.
Updates the mail_message_t database to indicate the number of
MIME parts, and also update club_t kbytes_in_use to keep track
of the amount of disk storage the club is using.

=head1 SYNOPSIS

    use Bivio::Mail::Store::MIMEDecode;
    Bivio::Mail::Store::MIMEDecode->new($mail_incoming, $file_name, $file_client)

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
Ultimately, it will also parse text/html parts.

=cut

#=IMPORTS

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

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Mail::Incoming mail_incoming, string file_name, Bivio::File::Client file_client) : Bivio::Mail::Store::MIMEDecode

I<mail_incoming> is the mail message being sent to this club.
I<file_name> the name of the message (typically this is the message ID)
pre-pended with the path. i.e. '/clubname/messages/html'
I<file_client> is the L<Bivio::File::Client|The Bivio::File::Client>
object used to write the MIME parts.

=cut

sub new {
    my($proto, $mail_incoming, $file_name, $file_client) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
        message => $mail_incoming,
	parser => MIME::Parser->new(output_to_core => 'ALL'),
	file_name => $file_name,
	kbytes => 0,
	num_parts => 0,
	#accumulates keywords parsed from text/plain message parts.
	keywords => {},
	io_scalar => IO::Scalar->new(),
	file_client => $file_client,
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
    return shift->{$_PACKAGE}->{kbytes};
}

=for html <a name="get_num_parts"></a>

=head2 get_num_parts() : int

returns the number of MIME parts written to the file server.

=cut

sub get_num_parts {
    return shift->{$_PACKAGE}->{num_parts};
}

=for html <a name="parse_and_store"></a>

=head2 parse_and_store()

Call this method to parse and write all MIME encoded parts to
the appropriate file name on file_client.

=cut

sub parse_and_store {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($msg) = $fields->{message};
    Carp::croak('Mail incoming is undefined') unless $msg;
    my($file_name) = $fields->{file_name};
    my($keywords) = $fields->{keywords};

    # we know the first part is the main mail message. We want
    # to store keywords For Subject, To, Date, and From fields
    _parse_keywords($msg->get_subject(), $keywords);
    _parse_keywords($msg->get_reply_to(), $keywords);
    _parse_keywords($msg->get_dttm(), $keywords);
    # now extract all the MIME attachments
    _trace('extracting MIME attachments for mail message. File: ',
	    $file_name) if $_TRACE;
    _extract_mime($fields, $fields->{parser}->read(
	    $msg->get_rfc822_io()), $file_name);
#    _extract_mime($fields->{parser}->read($msg->get_rfc822_io()),
#	    $file_name, undef, $keywords, \$fields->{num_parts},
#	    \$fields->{kbytes});
    my($rslt);
    $fields->{file_client}->set_keywords($file_name, $keywords, \$rslt)
	    || die("set_keywords failed: \$rslt");
    _trace('total bytes written (MIME): ', $fields->{kbytes}, ' K') if $_TRACE;
    return;
}

#=PRIVATE METHODS

# _extract_mime(hash_ref fields, MIME::Entity entity, string file_name)
#
# Extracts sub mime parts for this mime entity. This method is called
# recursively. kbytes is incremented every time we write a MIME Entity to
# file storage.
#
sub _extract_mime {
    my($fields, $entity, $file_name) = @_;
    Carp::croak('no entity was passed to _extract_mime()') unless $entity;
#   $fields->{keywords}, $fields->{num_parts}, and $fields->{kbytes}
    _trace('file_name: ', $file_name) if $_TRACE;
    _trace('head: ', $entity->head()) if $_TRACE;
    _parse_mime($fields, $entity,
	    Bivio::Type::MIMEType->from_content_type(
		    $entity->head->get('content-type')));

#TODO parse for keyword storage if MIME part content type is HTML
#right now, we're only parsing for keywords MIME type "plain-text".
    _write_entity_to_file($fields, $entity, $file_name);

    my(@parts) = $entity->parts();
    _trace('number of parts for this MIME part is ', int(@parts)) if $_TRACE;
    return unless @parts;

#TODO: BTW, From the man page of MIME::Entity
#           Note: for multipart messages, the preamble and
#           epilogue are not considered parts.  If you need them,
#           use the preamble() and epilogue() methods.

    # $i used only for trace
    my($i) = -1;
    my($subentity);
    for $subentity (@parts) {
	_trace('getting part ', ++$i) if $_TRACE;
	_trace('subentity is valid') if $_TRACE && $subentity;
	$content_type = Bivio::Type::MIMEType->from_content_type(
		$subentity->head->get('content-type'));
#TODO: BTW, 'eq' is a binary operator, not a method.  eq(bla) is not 
#      appropriate syntax.
#TODO: Use == on enums.  Use :: form, because faster and 'ok' in this case.
	if ($content_type == Bivio::Type::MIMEType::MESSAGE_RFC822()) {
#TODO We need to do the same thing for message/digest
	    _trace('part', $i, ' is an rfc822 message.') if $_TRACE;
	    my($parser) = MIME::Parser->new(output_to_core => 'ALL');
            my($root_entity) = $parser->read(
		    $subentity->bodyhandle->open('r'));
	    _trace('reading...') if $_TRACE;
	    _trace('NO ROOT ENTITY WAS FOUND.') if $_TRACE && !$root_entity;
	    return unless $root_entity;
	    _extract_mime($fields, $root_entity, $file_name."_$i");
	}
	elsif ($content_type == Bivio::Type::MIMEType::TEXT_PLAIN()) {
	    _trace('part content type is text/plain.'
		    .' calling _extract_mime on it') if $_TRACE;
	    _extract_mime($fields, $subentity, $file_name."_$i");
	}
	_trace('done with part ', $i) if $_TRACE;
    }
    return;
}

# _extract_mime_body_decoded(hash_ref fields, MIME::Entity entity) : scalar_ref
#
# Extracts the body of a MIME Entity decoded.
#
sub _extract_mime_body_decoded {
    my($fields, $entity) = @_;
    my($s);
    my($file) = $fields->{io_scalar};
    $file->open(\$s);
    my($io) = $entity->open('r');
    if (defined($io)) {
	my($line);
	$file->print($line) while defined($line = $io->getline);
	$io->close();
    }
    $file->close();
    return \$s
}

# _extract_mime_header(hash_ref fields, MIME::Entity entity) : string
#
# Extracts the MIME Header out of the entity. Returns it
# as a scalar.
sub _extract_mime_header {
    my($fields, $entity) = @_;
    _trace('>>printing mime header to IO::Scalar<<') if $_TRACE;
    my($s);
    my($file) = $fields->{io_scalar};
    $file->open(\$s);
    $entity->head->print($file);
    _trace('done writing mime_header');
    $file->close();
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

#TODO: Algorithm probably need to take into account hyphenated words.
    my($w);
    $str =~ s/[\'\"\.\;\:]//g;
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;
}

# _parse_mime(hash_ref fields, MIME::Entity entity, Bivio::Type::MIMEType content_type )
#
# Parses a MIME entity. If the MIME type is text/plain,
# then _parse_msg_line is called for each line of the content.
# _parse_msg_line will modify $fields->{keywords}, appending to it
# all keywords found in the text line.
#
sub _parse_mime {
    my($fields, $entity, $content_type) = @_;
    _trace('CONTENT_TYPE: ' , $content_type) if $_TRACE;
    if($content_type eq(Bivio::Type::MIMEType->TEXT_PLAIN)){
	_trace('content type TEXT_PLAIN. Parsing for keywords') if $_TRACE;
        my($file) = IO::Scalar->new(_extract_mime_body_decoded(
		$fields, $entity));
	while (!$file->eof) {
	    my($line) = $file->getline();
	    _parse_msg_line($line, $fields->{keywords});
	}
    }
    return;
}

# _parse_msg_line(scalar line)
#
# Called for each line of a MIME part that is text/plain.
#
sub _parse_msg_line {
    my($str, $keywords) = @_;
    unless (length($str)) {
	_trace('line is zero length, ignoring') if $_TRACE;
	return;
    }
#TODO: Handle multi-line tags.
    $str =~ s/--//g;
    $str = lc($str);
    $str =~ s/\&[a-z]//g;
    $str =~ s/\<.*\>//g;
    $str =~ s/[.]\s//g;
    $str =~ s/[!#%^&*,();:\t\[\]]//g;
    # Strip leading spaces so split works nicely.
    $str =~ s/^\s+//;
    my($w);
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;
}

# _write_entity_to_file(hash_ref fields, MIME::Entity entity, string file_name)
#
# Writes the mime header and body content to a file.
# modifies $fields->{kbytes} and $fields->{num_parts}
# entity : the L<MIME::Entity|MIME::Entity> you want to write
# file_name : the name of the file (fully qualified path)
# fields : member variables from this object (_PACKAGE_)
sub _write_entity_to_file {
    my($fields, $entity, $file_name) = @_;
    #extract the header and body, and shove them into a string.
    #probably I should re-use a scalar ref or an IO handle for both of these.
    my($msg_hdr) = _extract_mime_header($fields, $entity);
    die('header is undef') unless defined($msg_hdr) && length($msg_hdr);
    my($msg_body) = _extract_mime_body_decoded($fields, $entity);
    _trace('no body in this MIME Entity')
	    if $_TRACE && !(defined($$msg_body) && length($$msg_body));
    $msg_hdr .= $$msg_body if $$msg_body;
    $fields->{kbytes} += length($msg_hdr)/1024;
    _trace('kbytes: ', $fields->{kbytes}) if $_TRACE;
    $fields->{file_client}->create($file_name, \$msg_hdr)
	    || die("write failed: $msg_hdr");
    $fields->{num_parts}++;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
