# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mime::MimeParse;
use strict;
$Bivio::Biz::Mime::MimeParse::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Mime::MimeParse - a mime parsing engine.

=head1 SYNOPSIS

    use Bivio::Biz::Mime::MimeParse;
    Bivio::Biz::Mime::MimeParse->new();

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Mime::MimeParse::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Mime::MimeParse> is a simple MIME parsing engine.
It takes a MailIncoming object, and parses out the MIME parts.
Additionally, it creates a keyword hash of all words found in all
text/plain MIME parts. Ultimately, it will also parse HTML
parts.

=cut

#=IMPORTS
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Agent::HTTP::Request;
use Bivio::Mail::Incoming;
use IO::Scalar;
use MIME::Parser;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

my($_FILE_CLIENT);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(MailIncoming mail) : Bivio::Biz::Mime::MimeParse


=cut

sub new {
    my($proto, $mailincoming, $filename, $fclient) = @_;
    $_FILE_CLIENT = $fclient;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    my($parser) = MIME::Parser->new(output_to_core => 'ALL');
    my(%keywords) = (); #accumulates keywords parsed from text/plain message parts.
    $self->{$_PACKAGE} = {
        message => $mailincoming,
	parser => $parser,
	filename => $filename,
	keywords => \%keywords,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="parse"></a>

=head2 parse() : void

Call this method to parse and store all MIME encoded parts.

=cut

sub parse {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my $msg = $fields->{message};
    if(!$msg){
	&_trace("Mail incoming is undefined!") if $_TRACE;
    }
    my $file = $msg->get_rfc822_io(); #creates a file handle from the message
    my $entity  = $fields->{parser}->read($file);
    my $keywords = $fields->{keywords};
    my $filename = $fields->{filename};
    #we know the first part is the main mail message. We want
    #to store keywords for subject, to, date, and from fields
    _parse_keywords($msg->get_subject(), $keywords);
    _parse_keywords($msg->get_reply_to(), $keywords);
    _parse_keywords($msg->get_dttm(), $keywords);
    # now extract all the mime attachments
    &_trace('extracting MIME attachments for mail message. File: ', $filename) if $_TRACE;
    # the second field is the file "extension". For the main message part, this should
    # be undef since there is no .0, .1, .0.1 suffix
    _extract_mime($entity, $filename, undef);
    return;
}

#=PRIVATE METHODS

# _extract_mime(Entity entity) : void
#
# Extracts sub mime parts for this mime entity. This method is called
# recursively.
#
sub _extract_mime {
    my($entity, $filename, $ext) = @_;
    _parse_mime($entity); #parses keywords if this is text/plain

    #TODO parse it if it is HTML

    _write_mime($entity, $filename, $ext);

    my $numparts = $entity->parts || 0;
    my $i = 0;
    if($numparts eq(0)){return;}
    for($i = 0; $i < $numparts; $i++){
	my $subentity = $entity->part($i);
	_extract_mime($subentity, $filename, '_' . $i); #recurse
    }
    return;
}

# _extract_mime_body_decoded(MIME_Entity entity) : 
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

# _extract_mime_header(Entity entity) : string
#
# Extracts the MIME Header out of the entity. Returns it
# as a scalar.
sub _extract_mime_header {
    my($entity) = @_;
    my($s);
#TODO: use single file handle to avoid leaks
    my $file = IO::Scalar->new(\$s);
    my($head) = $entity->head;
    &_trace('>>printing mime header to IO::Scalar<<') if $_TRACE;
    $head->print($file);
    &_trace('done writing mime_header');
    return $s;
}

# _parse_keywords(scalarref str, Hashref keywords) : void 
#
# This method parses single line of text. 
#
#
sub _parse_keywords {
    my($str, $keywords) = @_;

    #this is not necessarily an error:
    if(!$str){return;}

    my($w);
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;
}

# _parse_mime(Entity entity) : void
#
# Parses a MIME entity. If the MIME type is text/plain,
# then _parse_msg_line is called for each line of the content.
#
sub _parse_mime {
    my($entity) = @_;
    my($ctype) = lc($entity->head->get('content-type'));
    if($ctype =~ /text-plain/){ #then we want keywords from it
	my $body = _extract_mime_body_decoded($entity);
        my $file = IO::Scalar->new(\$body);
	while(!$file->eof){
	    _parse_msg_line($file->getline());
	}
    }
    return;
}

# _parse_msg_line(scalarref line) : 
#
# Called for each line of a MIME part that is text/plain.
#
sub _parse_msg_line {
    &_trace("_parse_msg_line called.") if $_TRACE;
    my($line, $keywords) = @_;
    my($str) = $$line;
    if (!$$line){
	return;
    }
#TODO: Handle multi-line tags.
    $str =~ s/--//g;
    $str = lc($str);
#TODO: what about "gt", "lt", etc.  Need general alg, e.g. "\&[a-z]+;".
    $str =~ s/nbsp//g;
    $str =~ s/\<.*\>//g;
    $str =~ s/[.]\s//g;
#TODO: Careful about stripping e-mail addrs.  Want to enter foo@bar.com as
#      a complete keyword.

    # Hmmmm.
    $str =~ s/[!@#%^&*,();:\t\[\]]//g;
    # Strip leading spaces so split works nicely.
    $str =~ s/^\s+//;
    my($w);
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;

}

# _write_mime(Entityref entity, string suffix) : void
#
# Writes the mime header and body content to a file.
# Appends suffix to the filename.
#
sub _write_mime {
    my($entity, $filename, $suffix) = @_;
    my($ext) = $suffix || "";
    #extract the header and body, and shove them into a string.
    #probably I should re-use a scalar ref or an IO handle for both of these.
    my $msghdr = _extract_mime_header($entity);
    if(!$msghdr){
	die('the message header is undef');
    }
    my $msgbody = _extract_mime_body_decoded($entity);
    if(!$$msgbody){
	#this may not be an error at all. multipart/mixed might contain no body.
	#However, I thought I would get the 'this is a multipart message in MIME
	#format in the body. It seems to DISAPPEAR when the parser is done with it.
	#shit.
	&_trace('the message contains no body') if $_TRACE;
    }
    my $msg = $msghdr;
    if($$msgbody){$msg .= $$msgbody;}
    $_FILE_CLIENT->create($filename . $ext, \$msg) || die("write failed: $$msg");
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
