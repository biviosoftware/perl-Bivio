# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
#TODO: Mime::MimeParse is redundant.  Should also be "MIME" since
#      1) that's the perl package's name and 2) it is an acronym, not a word
#TODO: This probably should be in Bivio::Mail, e.g. Bivio::Mail::Store or
#      Bivio::Mail::Write or something that identifies it is reading
#      a mail message and writing it out in a very specific way including
#      keyword parsing.
#      Moreover, you should think that the file format needs to be
#      "well known".  There is probably a complimentary module:
#      Bivio::Mail::Retrieve.  This parallels the relationship with
#      Bivio::SQL::* which "supports" Bivio::Biz::*.
#      This isn't a generic MIME Parser since it takes a Bivio::Mail::Incoming
#      as its main argument.  It can only be used to store mail messages.
#
package Bivio::Biz::Mime::MimeParse;
use strict;
$Bivio::Biz::Mime::MimeParse::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

#TODO: try to be more descriptive
Bivio::Biz::Mime::MimeParse - splits mail messages into mime parts and stores

=head1 SYNOPSIS

    use Bivio::Biz::Mime::MimeParse;
#TODO: Correct this to match the actual args
    Bivio::Biz::Mime::MimeParse->new();

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Mime::MimeParse::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Mime::MimeParse> is a simple MIME parsing engine.
It takes a
#TODO: Use actual links so pod2html can generate appropriate links
L<Bivio::Mail::Incoming|Bivio::Mail::Incoming>
object, and recursively parses out the
MIME parts. Additionally, it creates a keyword hash of all
words found in all text/plain MIME parts.
Ultimately, it will also parse HTML parts.

=cut

#=IMPORTS
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Carp ();
use IO::Scalar;
use MIME::Parser;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
#TODO: Pass this in to new, so don't need config in this module.
#TODO: Define config variables before call to Config->register,
#      b/c config register can call back at the point of registration.
#      In general, Config->register should be last thing in #=VARIABLES
#      section.
my($_FILE_CLIENT);
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});


=head1 FACTORIES

=cut

#TODO: name variables with words separated by underscores.
#TODO: types in doc should match actual package names.  Abbreviations
#      such as MailIncoming won't get replaced by a global replace.

=for html <a name="new"></a>

=head2 static new(Bivio::Mail::Incoming mail_incoming, string file_name, Bivio::File::Client file_client) : Bivio::Biz::Mime::MimeParse

#TODO: Need a comment here.  What do the parameters mean?

=cut

sub new {
#TODO: be consistent on abbreviations: fname and fclient or
#      file_name and file_client.  It makes for easier reading (why did
#      he use "f" here and "file" there?) 
    my($proto, $mail_incoming, $file_name, $file_client) = @_;
#    $_FILE_CLIENT = $fclient;
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

=for html <a name="parse"></a>

#TODO: : void is not used.  It is superfluous.

=head2 parse()

#TODO: It is interesting you call this "parse" when it does parse
#      and store.  This was a complaint about perl's MIME::Parse,
#      i.e. it does more than parse, it also writes.  How about
#      store or write?
Call this method to parse and store all MIME encoded parts.

=cut

sub parse {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($msg) = $fields->{message};
#TODO: Invalid usage
#    if(!$msg){
#	_trace("Mail incoming is undefined!") if $_TRACE;
#    }
    Carp::croak('Mail incoming is undefined') unless $msg;
#TODO: Don't use intermediates unless used in a loop or something several
#    my($file) = $msg->get_rfc822_io(); #creates a file handle from the message
    my($file_name) = $fields->{file_name};
#      times within a method.
#    my($entity)  = $fields->{parser}->read($file);
    my($keywords) = $fields->{keywords};
#    my($num_parts) = $fields->{num_parts};
    #we know the first part is the main mail message. We want
    #to store keywords For Subject, To, Date, and From fields
    _parse_keywords($msg->get_subject(), $keywords);
    _parse_keywords($msg->get_reply_to(), $keywords);
    _parse_keywords($msg->get_dttm(), $keywords);
    # now extract all the MIME attachments
#TODO: Break lines at less than 80 chars.  It may seem archane, but
#   you break them somewhere so might as well be the same for everyone.
    _trace('extracting MIME attachments for mail message. File: ',
	    $file_name) if $_TRACE;
    # the second field is the file "extension". For the main message part,
    # this should be undef since there is no _0, _1, _0_1 suffix
    _extract_mime($fields->{parser}->read($msg->get_rfc822_io()),
	    $file_name, undef, $keywords, \$fields->{num_parts});
#TODO: not need   $fields->{num_parts} = $num_parts;
    _trace('getting all the keywords we found...') if $_TRACE;
#   my($k) = $fields->{keywords};
#   my(@keys) = keys %$k;
#   print(STDERR "KEYWORDS-------------------------------");
#   while(@keys){
#	print(STDERR "\n\"" . pop(@keys) . "\"");
#   }
#   print(STDERR "\n");
#   _trace('Writing the keywords to the file') if $_TRACE;
    my($rslt);
    $_FILE_CLIENT->set_keywords($file_name, $keywords, \$rslt)
	    || die("set_keywords failed: \$rslt");
    _trace('done with the keyword storage.') if $_TRACE;
    return;
}

#=PRIVATE METHODS

#TODO; syntax of types and case
# _extract_mime(Entity entity, String file_name, String ext, Hashref keywords) : void
# _extract_mime(MIME::Entity, string file_name, string ext, hash_ref keywords)
#
# Extracts sub mime parts for this mime entity. This method is called
# recursively.
#
sub _extract_mime {
    my($entity, $file_name, $ext, $keywords, $tnum_parts) = @_;
#TODO: Incorrect $_TRACE usage.
#    if(!$entity) {
#	die('no entity was passed to _extract_mime()') if $_TRACE;
#    }
    Carp::croak('no entity was passed to _extract_mime()') unless $entity;
    _trace('file_name: ', $file_name, ' ext: ', $ext) if $_TRACE;
    # parses keywords only if this is text/plain
    _parse_mime($entity, $keywords);
#TODO: No need to pass in "$ext" separately.  Could just be $file_name
#      and which caller appends.  Simplifies interface and logic here.
    $file_name .= $ext || "";
    _trace('file_name after concat: ', $file_name) if $_TRACE;

#TODO parse for keyword storage if MIME part content type is HTML
#right now, we're only parsing for keywords MIME type "plain-text".

#TODO: The comment "writes the mime to a file" is distracting and superflous.
#      Name the method write_entity_to_file if you think the method name
#     is unclear, but commenting it in one place doesn't improve the self-
#     documenting effect.
#    _write_mime($entity, $file_name, $tnum_parts); #writes the mime to a file.
    _write_mime($entity, $file_name, $tnum_parts);

    my($num_parts) = $entity->parts || 0;
    my($i) = 0;
    _trace('number of parts for this MIME part is ', $num_parts) if $_TRACE;
#TODO: Saying "eq(0)" is unnecessary.
#    if($num_parts eq(0)){
#	return;
#    }
#Rather:
    return unless $num_parts;

    for ($i = 0; $i < $num_parts; $i++){
#TODO: Get in the habit of always using trace.  That way you don't have to
#      comment out print STDERR lines when you checkin.  There's no way
#      I can know where "getting part" is coming from without searching
#      all the code.  Makes for incomprehensible log messages--all STDERR
#      lines go to a log.  Also, use ",", to allow _trace to handle
#      each object separately.  _trace will truncate excessive leng args.
#	print(STDERR "getting part " . $i . "\n");
	_trace('getting part ', $i) if $_TRACE;
	my($subentity) = $entity->part($i);
	my($head) = $subentity->head();
#TODO: I don't know if MIME::Parse automatically downcases, but I doubt it.
#	my($ctype) = $head->get('content-type');
#	if ($ctype =~ /message\/rfc822/) {
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
	    _trace('the MIME part is an rfc922 message. Sub parsing this...') if $_TRACE;
	    my($parser) = MIME::Parser->new(output_to_core => 'ALL');
            my($root_entity) = $parser->read(
		    $subentity->body_handle->open('r'));
#TODO: Conditionals and trace.  Any logic should be "inside" the $_TRACE
#      This test is executes the minimum amount of code in $_TRACE is off.
#TODO: Is this the right logic?  Do you want to the trace and extract
#      anyway? Won't it crash?
	    _trace('NO ROOT ENTITY WAS FOUND.') if $_TRACE && !$root_entity;
	    _extract_mime($root_entity, $file_name, '_' . $i,
		    $keywords, $tnum_parts);
	}
	elsif ($ctype =~ m!^\s*text/plain\s*(?:\;|$)!) {
	    # then we want keywords from it
#TODO:	avoid: print(STDERR "message is text plain.\n");
	    _trace('part is text/plain') if $_TRACE;
	    _extract_mime($subentity, $file_name, '_' . $i, $keywords,
		    $tnum_parts);
	}
    }
    return;
}

#TODO: syntax of type:
# _extract_mime_body_decoded(MIME_Entity entity) : scalar_ref
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

#TODO: syntax of type:
# _extract_mime_header(Entity entity) : string
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

#TODO: syntax of type:
# _parse_keywords(scalarref str, Hashref keywords) : void 
# _parse_keywords(string_ref str, hash_ref keywords)
#
# This method parses single line of text.
#
sub _parse_keywords {
    my($str, $keywords) = @_;

    # this is not necessarily an error:
#TODO: Avoid if(){return} syntax.  There is more syntax than the alternative
#    if(!$str){return;}
    return unless $str;

#TODO: Don't want punctuation in keywords or contractions (Don't).
#      Algorithm probably need to take into account hyphenated words.
    my($w);
    foreach $w (split(/\s+/, $str)) {
	$keywords->{$w}++;
    }
    return;
}

#TODO: syntax of type:
# _parse_mime(Entity entity) : void
# _parse_mime(MIME::Entity entity)
#
# Parses a MIME entity. If the MIME type is text/plain,
# then _parse_msg_line is called for each line of the content.
#
sub _parse_mime {
    my($entity, $keywords) = @_;
#TODO: At this point, don't want to keep getting "ctype".  Probably
#      want to pass it in and maybe even have an integer or enum for
#      the special types.
    my($ctype) = lc($entity->head->get('content-type'));
    _trace('PARSE THE MIME: the mime type is ', $ctype) if $_TRACE;
    if ($ctype =~ /text\/plain/) {
	# then we want keywords from it
#TODO:	print(STDERR "message is text plain.\n");
	_trace('message is text/plain') if $_TRACE;
#TODO: avoid "my $file" since the convention we use is my($file).  If
#      you want to change the style, bring it up via mail or at a meeting.
#      I don't care what it is, but inconsistency can be an indicator
#      of code which wasn't written carefully.  It leaves the reader
#      to ask the question: Why is this different?
        my($file) = IO::Scalar->new(_extract_mime_body_decoded($entity));
	while (!$file->eof) {
#TODO:	    print(STDERR ".");
#TODO: In this case, it makes sense to not pass the string_ref.  If
#      performance becomes an issue, can always use "$_" implicitly.
	    my($line) = $file->getline();
	    _parse_msg_line(\$line, $keywords);
	}
	print(STDERR "done parsing\n");
    }
    return;
}

# _parse_msg_line(scalarref line) : 
#
# Called for each line of a MIME part that is text/plain.
#
sub _parse_msg_line {
    _trace("_parse_msg_line called.") if $_TRACE;
    my($line, $keywords) = @_;
    my($str) = $$line;
    if (!$$line) {
#TODO:	print(STDERR "THE LINE IS NULL\n");
	return;
    }
    print(STDERR "THE LINE IS \"" . $$line . "\n");
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

#TODO: Incorrect param decl
# _write_mime(Entityref entity, string file_name) : void
# _write_mime(MIME::Entity entity, string file_name, int_ref parts)
#
# Writes the mime header and body content to a file.
#
sub _write_mime {
    my($entity, $file_name, $parts) = @_;
    #extract the header and body, and shove them into a string.
    #probably I should re-use a scalar ref or an IO handle for both of these.
    my($msg_hdr) = _extract_mime_header($entity);
#TODO: Avoid tests like this on scalars.  Ok on refs and arrays
#    if(!$msg_hdr){
#TODO: Don't need _write_mime, because prefixed by _trace
#	die('the message header is undef in _write_mime.');
#    }
    die('header is undef') unless defined($msg_hdr) && length($msg_hdr);
    my($msg_body) = _extract_mime_body_decoded($entity);
#TODO: logic on traces
#    if(!$$msg_body){
#	#this may not be an error at all. multipart/mixed might contain no body.
#	_trace('the message contains no body') if $_TRACE;
#    }
    _trace('no body')
	    if $_TRACE && !(defined($$msg_body) && length($$msg_body));
#TODO: assignment is superfluous, since you don't use msg_hdr again
#    my($msg) = $msg_hdr;
#TODO: If test is superfluous, since just tested a line above
#   if($$msg_body){$msg .= $$msg_body;}
    $msg_hdr .= $$msg_body;
    $_FILE_CLIENT->create($file_name, \$msg_hdr)
	    || die("write failed: $msg_hdr");
#TODO: Why pass this in.  It is always incremented, so not really part
#      of the problem of writing mime.  Can easily do in caller and
#      simplifies interface.
    #increment the parts counter:
    $$parts++;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
