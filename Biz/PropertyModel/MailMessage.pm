# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$

package Bivio::Biz::PropertyModel::MailMessage;
use strict;

$Bivio::Biz::PropertyModel::MailMessage::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::MailMessage - an email message

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::MailMessage;
    Bivio::Biz::PropertyModel::MailMessage->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::MailMessage::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::MailMessage> holds information about an email
message, the body of which is stored in the file server.

=cut

#=IMPORTS
use MIME::Parser;
use IO::File;
use IO::Stringy;
use IO::Scalar;
use Bivio::Biz::FieldDescriptor;
use IO::Scalar;
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::PrimaryId;
use Bivio::SQL::Support;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_SQL_SUPPORT);
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});

my($_FILE_CLIENT);

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Bivio::Mail::Incoming msg, Bivio::Biz::PropertyModel::RealmOwner realm_owner, Bivio::Biz::PropertyModel::Club club)

Creates a mail message model from an L<Bivio::Mail::Incoming>.

=cut

sub create {
    my($self, $msg, $realm_owner, $club) = @_;
    # Archive mail message first
    my($mbox) = $msg->get_unix_mailbox;
    # $dttm is always valid
    my($dttm) = $msg->get_dttm() || time;
    my($mon, $year) = (gmtime($dttm))[4,5];
    $year < 1900 && ($year += 1900);
    my($club_id, $club_name) = $realm_owner->get('realm_id', 'name');

#    my $result = $_FILE_CLIENT->create('/'. $club_name . '/messages/'
#	    . sprintf("%04d%02d", $year, ++$mon), \$mbox) || die("mbox create failed: $mbox");

    $_FILE_CLIENT->append('/'. $club_name . '/mbox/'
	    . sprintf("%04d%02d", $year, ++$mon), \$mbox)
	    || die("mbox append failed: $mbox");
#TODO:: Need to truncate these.  If from_email is too long, what to do?
    my($from_email, $from_name) = $msg->get_from();
    defined($from_name) || ($from_name = $from_email);
    my($reply_to_email) = $msg->get_reply_to();
    my($body) = $msg->get_body();
    my($values) = {
	'club_id' => $club_id,
	'rfc822_id' => $msg->get_message_id,
	'dttm' => $dttm,
	'from_name' => $from_name,
	'from_email' => $from_email,
	'reply_to_email' => $reply_to_email,
	'subject' => $msg->get_subject || '',
#TODO:: Measure real size (all unpacked files)
	'kbytes' => int((length($body) + 1023)/ 1024),
	'subject_sort' => &_sortable_subject($msg->get_subject( ) || '',
		$club_name),
	'from_name_sort' => &_sortable_name($from_name, $from_email)
    };
    $self->SUPER::create($values);
    my $msgid = $self->get('mail_message_id');
#TODO:: Update club_t.bytes here
    $_FILE_CLIENT->create('/' . $club_name . '/messages/rfc822/'
	    . $values->{mail_message_id}, \$body)|| die("create of file failed: $body");

    # Handle email attachments. Here's a first cut...
    my $parser = new MIME::Parser(output_to_core => 'ALL');
    my $file = $msg->get_rfc822_io();
    
    #change this. We're not saving the header.
    $_FILE_CLIENT->create('/' . $club_name . '/messages/'
	    . $msgid, \$body)
	    || die("file server failed: $body");

    my $entity = $parser->read($file);

    #now extract all the mime attachments
    &_trace('extracting MIME attachments for this mail message') if $_TRACE;
#    my $msgid = $values->{mail_message_id};
    _extract_mime($entity, 0, $club_name, $msgid);
    
    #crude reset of the file position:
    $file = $msg->get_rfc822_io();
    my $keywords = _parse_keywords($file);
    $file->close;
    my $rslt = "";
    $_FILE_CLIENT->set_keywords('/' . $club_name . '/messages/html/' . $values->{mail_message_id} . ".0",
	    $keywords,
	    \$rslt);
    return;
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;
    die("not supported");
}


=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item file_server : string (required)

Where are the messages stored.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_FILE_CLIENT = Bivio::File::Client->new($cfg->{file_server});
    return;
}

=for html <a name="get_body"></a>

=head2 get_body() : string_ref

Returns the htmlized body of the mail message. This is retrieved from the
file server using the path "club-id/messages/message-id".

=cut

sub get_body {
    my($self) = @_;
    my($body);
    $_FILE_CLIENT->get('/'.$self->get('club_id')
	    .'/messages/'.$self->get('mail_message_id'),
	    \$body) || die("couldn't get mail body");
    return \$body;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    return Bivio::SQL::Support->new('mail_message_t', {
        mail_message_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
        club_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::NONE()],
        rfc822_id => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NOT_NULL_UNIQUE()],
        dttm => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::NOT_NULL()],
        from_name => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NOT_NULL()],
        from_name_sort => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NOT_NULL()],
        from_email => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NOT_NULL()],
        reply_to_email => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NONE()],
        subject => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NOT_NULL()],
        subject_sort => ['Bivio::Type::Line',
		Bivio::SQL::Constraint::NOT_NULL()],
        kbytes => ['Bivio::Type::Integer',
		Bivio::SQL::Constraint::NOT_NULL()],

    });
}
=for html <a name="setup_club"></a>

=head2 setup_club(Bivio::Biz::PropertyModel::Club club)

Creates the club message storage area.

=cut

sub setup_club {
    my($self, $club) = @_;
    my($res);
    my($club_name) = $club->get('name');
    my($dir);
    foreach $dir ($club_name, "$club_name/mbox", "$club_name/messages/rfc822", "$club_name/messages/html") {
	$_FILE_CLIENT->mkdir($dir, \$res) || die("mkdir $dir: $res");
    }
    return;
}

#=PRIVATE METHODS

# _get_date(line : string reference) : string
#
# Probably should return a reference.
# This method extracts a DATE from the line.
# Note the assumption is we are parsing a message header, where the line
# BEGINS with Date:, rather than parsing a date that might occur inside
# the mail message body. 
#
#TODO: don't assume this is a mail header field. 
sub _get_date {
    my($line) = @_;
    if($$line =~ s/^Date:\s*//){
	my @date = split /\s*/, $$line;
	return _todate(\@date);
    }
}

# _parse_keywords(file : IO::File) : void
#
# parses the mail message for all words.
# Note that right now, this method is receiving an IO::Handle from
# the mail message which includes the mail header. We should just be
# parsing the mail *body*
#
sub _parse_keywords {
    my($file) = @_;
    &_trace("_parse_keywords called.") if $_TRACE;
    my %keywords;# = {};
    LOOP : while(!$file->eof( )){
	my $line = $file->getline( );
	&_trace($line) if $_TRACE;
	if($line =~ /^Date:/){
	    my $fdate = _get_date(\$line);
	    next LOOP;
	}
	if($line =~ s/^From:\s*//){
	    next LOOP;
	}
	if($line =~ s/^To:\s*//){
	    next LOOP;
	}
	if($line =~ s/^Subject:\s*//){
	    next LOOP;
	}
	_parse_msg_line(\$line, \%keywords);

    }
    my(@keys) = keys %keywords;
    my(@values) = values %keywords;
    my $totalwords = 0;
#    while(@keys){
#	my $n = pop(@values);
#	$totalwords += $n;
#	&_trace(pop(@keys) . "\" => " . $n) if $_TRACE;
#    }
#    &_trace("Total Number of Words: $totalwords") if $_TRACE;
    return \%keywords;
}

# _parse_msg_line(line : string reference, keywords : hash) : void
#
# parses a line of text, putting each word found into the
# supplied hash, incrementing the index (number of times this word
# is found in this line) in the hash or defining it as '1' if the
# word was not there already. This is not necessary, but was an easy
# way to put the words into the hash and has the added bonus that if
# we wanted to do "weighting" of words in messages, we could do that
# easily. The caller can simply ignore the number field for now
#
# NOTE: that this line also strips out unwanted chars. We take out
# ALL HTML! Also, I remove funky characters, and characters from HTML
# that are not normally encoded inside angle brackets (i.e. &nbsp)
#
# All words are stored lower case only.
#
#
#TODO: STORE THIS INFORMATION INTO THE FILE SERVER!
sub _parse_msg_line {
    my($line, $keywords) = @_;
    &_trace("_parse_msg_line called.") if $_TRACE;
    my $str = $$line;
    if(!$$line){
	print(STDERR "NULL LINE.\n");
	return;
    }
    $str =~ s/--//g;
    $str =~ s/nbsp//g;
    $str =~ s/\<.*\>//g;
    $str =~ s/[.]\s//g;
    $str =~ s/[!@#%^&*,();:\t\[\]]//g;
    #let's assume we don't care about case:
    $str = lc($str);
    #and let's put off worrying about if this is MSWord, Excel, etc.
    my @words = split /\s/, $str;
    for(my $x = 0; $x < $#words +1; $x++){
	my $n = $keywords->{$words[$x]};
	my $i = $n ? $n+1 : 1;
	if($words[$x] eq("")){
	    print(STDERR "found null word. Skipping.\n");
	}
	else{
	    &_trace("found: " . $words[$x]) if $_TRACE;
	    $keywords->{$words[$x]} = $i;
	}
    }
    
}

# _todate(date string) : string
# gets an array of elements, each corresponding to
# parts of the date stripped out of a line;
# [day][date][month-abbreviated][year][time][gmtoffset]
# receives an arrayref, returns a scalar (formatted string)
#
#
sub _todate {
    my($date) = @_;
    my $d = "@$date[2] ";
    $d .= @$date[1] =~ /\d\d/ ? @$date : "0" . @$date[1];
    $d .= " @$date[3]";
    return $d;
}


#NOTE: this method returns a scalar, not a reference.
#The mime header is assumed to be small.
#TODO: don't use tie'd handles. 
sub _extract_mime_header($ ){
    my($entity) = @_;
    my $s;
    tie *HEADERHANDLE, 'IO::Scalar', \$s;
    my $head = $entity->head( );
    $head->print(\*HEADERHANDLE);
    return $s;
}

#NOTE: this method returns a scalar reference.
#TODO: don't use tied handles.
sub _extract_mime_body_decoded($ ){
    my($entity) = @_;
    my $s;
    tie *FILEHANDLE, 'IO::Scalar', \$s;
    if (my $io = $entity->open("r")) {
       while (defined($_ = $io->getline)) { print (FILEHANDLE $_); }
       $io->close;
    }
    return \$s
    
}


sub _write_mime_header{
    my($club_name, $outputfilename, $hdr) = @_;
   $_FILE_CLIENT->create('/' . $club_name . '/messages/html/'
	. $outputfilename . "_hdr", $hdr)
	|| die("writing of mime header failed: $$hdr");
}



# filename, clubname scalarRef
sub _write_mime{
    my($filename, $clubname, $msg) = @_;
    &_trace('writing file: $filename') if $_TRACE;
    $_FILE_CLIENT->create('/' . $clubname . '/messages/html/'
    . $filename, $msg) || die("writing of mime part failed: $$msg");
}

# This method is supposed to extract each MIME "part" of the message
# and write each one to a file named <messageid>.<index>.
# Additionally, each MIME header is written to a file: <messageid>.<index>_hdr

sub _extract_mime{
    my($entity, $fileindex, $club_name, $message_id) = @_;
    &_trace('extract index: $fileindex') if $_TRACE;
    my($numparts) = $entity->parts( ) || 0; #number of parts;
    &_trace('number of parts: $numparts') if $_TRACE;

#    if($fileindex > 0 ){ # then we're probably talking about sub parts. Whatever that means.
    my $mime = _extract_mime_body_decoded($entity);
    my $outputfilename = $message_id . "." . $fileindex;
    my $msg = $$mime;
    my $textplain = 0;
    my $write=1;
    my $ctype = $entity->head->get('content-type');
    my $hdr = _extract_mime_header($entity);
    &_trace('content type: \"$ctype\"') if $_TRACE;
    if($mime){
	if($ctype =~ /multipart\/alternative/){
	    #maybe throw away the text/plain, and just write out the HTML
	    &_trace('content-type is multipart/alternative. Not writing this part.') if $_TRACE;
	    $write = 0;
	}
	if($ctype =~ /multipart\/mixed/){
	    &_trace('content type is multipart/mixed. Not writing this part.') if $_TRACE;
	    $write = 0;
	}
	if($ctype =~ /text\/plain/){
	    $textplain = 1;
	}
	if($textplain eq(1) && $write eq(1)){ 
	    &_trace('content type is text/plain') if $_TRACE;
	    &_trace('wrapping with <PRE></PRE>') if $_TRACE;
	    $msg = "<PRE>\n" . $msg . "\n</PRE>\n";
	    _write_mime($outputfilename, $club_name, \$msg);
            _write_mime_header($club_name, $outputfilename, \$hdr);
	}
	else{ #could be text/html or some other mime type
	    &_trace('content-type is not text/plain. it is \"$ctype\"') if $_TRACE;
	    if($write eq(1)){
		&_trace('writing straight through.') if $_TRACE;
		_write_mime($outputfilename, $club_name, \$msg);
		_write_mime_header($club_name, $outputfilename, \$hdr);
	    }
	}
    }

    &_trace('found $numparts elements. ') if $_TRACE;
    for(my $index=0; $index < $numparts; $index += 1){
	my $e = $entity->part($index);
	$fileindex = $fileindex + 1;
        _extract_mime($e, $fileindex, $club_name, $message_id);
    }
}

sub _sortable_subject {
     my($subject, $clubname) = @_;
     if(!$clubname){
       die('no club name supplied to _sortable_subject');
     }
     if(!$subject){
       die('no subject supplied to _sortable_subject');
     }
 
     $subject = lc($subject);
     $subject =~ s/^re:\s*($clubname)?//i;
     $subject =~ s/\W//gi;
     $subject .= "~";
     return $subject;
}

# constructs a string we can store and use as a "sortable" subject.
sub _sortable_name {
     my($from_name, $from_email) = @_;
     if(!$from_name){
       die('no from_name supplied to _sortable_name');
     }
     my($str) = lc($from_name .  " <" . $from_email . ">" );
     $str =~ s/[!#$%^&*-+=]/\s/g;
     return $str;
}


1;

