# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MailMessage;
use strict;

$Bivio::Biz::Model::MailMessage::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MailMessage - an email message

=head1 SYNOPSIS

    use Bivio::Biz::Model::MailMessage;
    Bivio::Biz::Model::MailMessage->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MailMessage::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MailMessage> holds information about an email
message, the body of which is stored in the file server.

#TODO: Better description of storage structure and usage.

=cut

#=IMPORTS
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::PrimaryId;
use IO::Scalar;
use MIME::Parser;
use Bivio::Mail::Store::MIMEDecode;
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

=for html <a name="copy_club"></a>

=head2 copy_club(Bivio::Biz::Model::RealmOwner source, Bivio::Biz::Model::RealmOwner dest)

Copies an I<source> club's files to I<dest> club.  I<dest> club must
not exist.

=cut

#sub copy_club {
#    my($self, $source, $dest) = @_;
#    my($res);
#    my($s) = $source->get('name');
#    my($d) = $dest->get('name');
#    $_FILE_CLIENT->copy($s, $d, \$res) || die("copy $s $d: $res");
#    return;
#}

=for html <a name="create"></a>

=head2 create(Bivio::Mail::Incoming msg, Bivio::Biz::Model::RealmOwner realm_owner, Bivio::Biz::Model::Club club)

Creates a mail message model from an L<Bivio::Mail::Incoming>.

=cut

sub create {
    my($self, $msg, $realm_owner, $club) = @_;
    # Archive mail message first
    # $dttm is always valid
    my($dttm) = $msg->get_dttm() || time;
    my($club_id, $club_name) = $realm_owner->get('realm_id', 'name');
    my($from_email, $from_name) = $msg->get_from;
    defined($from_name) || ($from_name = $from_email);
    my($reply_to_email) = $msg->get_reply_to;
    my($body) = $msg->get_body;
    my($subject) = $msg->get_subject;
#TODO: Should we allow NULL for subject?  Makes code elsewhere complicated,
#      but would be more true to what is actually going on.
    $subject = '(no subject)' unless $subject;
    my($values) = {
	club_id => $club_id,
	rfc822_id => $msg->get_message_id,
	dttm => Bivio::Type::DateTime->from_unix($dttm),
	from_name => $from_name,
	from_email => $from_email,
	reply_to_email => $reply_to_email,
	subject => $subject,
#TODO: Measure real size (all unpacked files)
	kbytes => int((length($body) + 1023)/ 1024),
	subject_sort => _sortable_subject($subject, $club_name),
	from_name_sort => _sortable_name($from_name, $from_email)
    };
    $self->SUPER::create($values);
    my($msgid) = $self->get('mail_message_id');
#TODO: Update club_t.bytes here
    _trace('validation of kbyte size for message.');

#TODO This is a two step process. Probably should move the whole thing
#into club.

    my($kbytes) = $values->{kbytes};
    #NOTE this is an estimate:
    my($isok) = $club->check_kbytes(\$kbytes);
    #kbytes is incremented if okay.
    if($isok eq(0)){
	die("Mail message size exceeds max size for club.");
    }

    my $rfc = $msg->get_rfc822();
    $_FILE_CLIENT->create('/'.$club_name.'/messages/rfc822/'.$msgid,
	    \$rfc) || die("create failed: $rfc");
#TODO: When parsing works, this should be taken out.
#return;
    # Handle email attachments. Here's a first cut...
    my $filename = '/' . $club_name . '/messages/html/' . $msgid;
    if($msg){
	&_trace('msg is not null when we call ctor MimeDecode.') if $_TRACE;
    }
    my $mimeparser = Bivio::Mail::Store::MIMEDecode->new($msg, $filename, $_FILE_CLIENT);
    $mimeparser->parse_and_store();
    # due to the above two lines, all the MIME stuff in this
    # file will be removed
    my($nparts) = $mimeparser->get_num_parts();
    $self->update({
	parts => $nparts,
    });
    my($curkbytes) = $club->get('kbytes_in_use') + $mimeparser->get_kbytes_written();
    _trace('updating kbytes_in_use for this club: ', $curkbytes) if $_TRACE;
#TODO There could be rounding error, here:
    $club->update({
	kbytes_in_use => $curkbytes,
    });
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

=for html <a name="get_keywords"></a>

=head2 get_keywords(void) : keywords (arrayref)

Will implement keyword "getting" for a mail message file.

=cut

#TODO implement this.

sub get_keywords {
    my($self) = @_;
    return;
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

=for html <a name="get_body"></a>

=head2 get_body() : string

Returns the htmlized body of the mail message. This is retrieved from the
file server using the path "club_name/messages/message-id".

=cut

sub get_body {
    my($self) = @_;
    my($body);
    my($club_id, $msg_id) = $self->get('club_id', 'mail_message_id');
    my($req) = $self->get_request;
#TODO: Need to make a general registry of models, so we share without
#      having to resort to tricks like this.
    $self->die(Bivio::DieCode::DIE(),
	    message => 'should not have gotten here')
	    unless $club_id eq $req->get('auth_id');
    my($club_name) = $req->get('auth_realm')->get('owner_name');
    my($filename) = '/'.$club_name.'/messages/html/'.$msg_id;
    die("couldn't get mail body: $body")
	    unless$_FILE_CLIENT->get($filename, \$body);
#TODO: This needs to be fixed to search for header separator(?)
    my($i) = index($body, '<!DOCTYPE');
    return $i == -1 ? '' : substr($body, $i);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mail_message_t',
	columns => {
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
            parts => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => 'club_id',
	other => [
	    [qw(club_id Club.club_id)],
	],
    };
}

=for html <a name="setup_club"></a>

=head2 static setup_club(Bivio::Biz::Model::RealmOwner club)

Creates the club message storage area.

=cut

sub setup_club {
    my(undef, $club) = @_;
    my($res);
    my($club_name) = $club->get('name');
    my($dir);
    foreach $dir ("$club_name", "$club_name/messages",
	    "$club_name/messages/rfc822", "$club_name/messages/html") {

	$_FILE_CLIENT->mkdir($dir, \$res) || die("mkdir $dir: $res");
    }
    return;
}

#=PRIVATE METHODS

# _extract_mime(MIME::Entity entity, int file_index, string club_name, string message_id)
#
# Extract each MIME "part" of the message and write each one to a file named
# [messageid].[index].  Additionally, each MIME header is written to a file:
# [messageid].[index]_hdr
#
sub _extract_mime {
    my($entity, $file_index, $club_name, $message_id, $suffix) = @_;
    &_trace('extract index: ', $file_index) if $_TRACE;
    my($num_parts) = $entity->parts || 0;
    &_trace('number of parts: ', $num_parts) if $_TRACE;

    my($mime) = _extract_mime_body_decoded($entity);
    my($output_file_name) = $message_id . $suffix ? "_$suffix" : undef;
    my($msg) = $$mime;
    my($textplain) = 0;
    my($write) = 1;
    my($ctype) = lc($entity->head->get('content-type'));
    my($hdr) = _extract_mime_header($entity);
    &_trace('content type: ', $ctype) if $_TRACE;
    if ($mime) {
	if ($ctype =~ /multipart\/alternative/) {
	    &_trace('content-type is multipart/alternative.') if $_TRACE;
	    $write = 1;
	}
	if ($ctype =~ /multipart\/mixed/) {
	    &_trace('content type is multipart/mixed.') if $_TRACE;
	    $write = 0;
	}
	if ($ctype =~ /text\/plain/) {
	    $textplain = 1;
	}
	if ($textplain && $write) {
	    &_trace('content type is text/plain') if $_TRACE;
	    &_trace('wrapping with <PRE></PRE>') if $_TRACE;
	    #TODO here is where we need to "reformat" the email for web browser display.
	    $msg = "<PRE>\n" . $msg . "\n</PRE>\n";
	    _write_mime($club_name, $output_file_name, \$msg);
            _write_mime_header($club_name, $output_file_name, \$hdr);
	    &_trace('now parsing the keywords for this mime part, since it is plain text.') if $_TRACE;
	    #moved keyword parsing here.
	    my $file = IO::Scalar->new(\$msg);
	    my($keywords) = _parse_keywords($file);
	    $file->close;
	    my($rslt) = '';
	    $_FILE_CLIENT->set_keywords('/'.$club_name.'/messages/html/'.$message_id . ".$file_index",
		    $keywords, \$rslt) || die("set_keywords failed: \$body");
	    &_trace('done with the keyword storage.') if $_TRACE;
	}
	else {
	    # could be text/html or some other mime type
	    &_trace('content-type is not text/plain. it is ', $ctype) if $_TRACE;
	    #TODO: We need to parse keywords for this IF it is text/html AND we did
	    #	   not already parse the text/plain part that is identical
	    if ($write) {
		&_trace('writing straight through.') if $_TRACE;
		_write_mime($club_name, $output_file_name, \$msg);
		_write_mime_header($club_name, $output_file_name, \$hdr);
	    }
	}
    }

    &_trace('found $num_parts elements. ') if $_TRACE;
    for (my($index) = 0; $index < $num_parts; $index += 1) {
	my($e) = $entity->part($index);
	$file_index = $file_index + 1;
        _extract_mime($e, $file_index, $club_name, $message_id);
    }
    return;
}

# _extract_mime_body_decoded(MIME::Entity entity) : string_ref
#
# Returns mime body for this entity.
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
# Returns mime header for this entity.
#
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

# _get_date(string_ref line) : string
#
# Probably should return a reference.
# This method extracts a DATE from the line.
# Note the assumption is we are parsing a message header, where the line
# BEGINS with Date:, rather than parsing a date that might occur inside
# the mail message body. 
#
sub _get_date {
    my($line) = @_;
#TODO: Use Mail::Incoming::get_dttm
    if ($$line =~ s/^Date:\s*//i) {
	my(@date) = split(/\s+/, $$line);
	return _to_date(\@date);
    }
#TODO: What should be returned here?
    return undef;
}

# _parse_keywords(IO::Handle file) : hash_ref
#
# parses the mail message for all words.
# Currently, this method is called for a MIME part that is
# only text/plain. It is not called for other mime parts.
# This means we don't ever see the Subject, Date, From, To
# Fields when this method is called.
#
sub _parse_keywords {
    my($file) = @_;
    &_trace('called') if $_TRACE;
    my(%keywords) = ();
    while (!$file->eof) {
	my($line) = $file->getline;
	if ($line =~ /^Date:/i) {
#TODO: use Mail::Incoming->get_dttm
	    my($fdate) = _get_date(\$line);
	}
	elsif ($line =~ s/^(?:From|To|Subject):\s*//i) {
#TODO: what is supposed to be here?
	    next;
	}
	_parse_msg_line(\$line, \%keywords);
    }
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
sub _parse_msg_line {
    my($line, $keywords) = @_;
    &_trace("_parse_msg_line called.") if $_TRACE;
    my($str) = $$line;
    if (!$$line){
# This condition should be ignored.
#	print(STDERR "NULL LINE.\n");
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

# _sortable_name(string from_name, string from_email) : string
#
# Returns from_name and from_email stripped and downcased for storing
# in the "from_name_sort" field.
#
sub _sortable_name {
    my($from_name, $from_email) = @_;
#TODO: Should do either from_name or from_email, not both.
    my($str) = lc($from_name .  " <" . $from_email . ">" );
    $str =~ s/[!#$%^&*-+=]/\s/g;
    &_trace('stripped user name: ', $str) if $_TRACE;
    return $str;
}

# _sortable_subject(string subject, string clubname) : string
#
# Returns a stripped, lowercase version of the subject line for
# storing in the "subject_sort" field.
#
sub _sortable_subject {
    my($subject, $clubname) = @_;
    my($reply_marker) = '';
    $subject = lc($subject);
    $subject =~ s/^\s*$clubname://;
    # Replies should come after the original message.  Strip
    # an "Re:" and put a tilde (~) on the end so will sort after
    # original subject.
    $subject =~ s/^\s*re:\s*(?:$clubname:)?// && ($reply_marker = '~');
    # Strip all non-alphanumerics
#TODO: should we be stripping spaces?
    $subject =~ s/[^a-z0-9]//g;
    return $subject . $reply_marker;
}

# _to_date(array_ref date) : string
#
# gets an array of elements, each corresponding to
# parts of the date stripped out of a line;
# [day][date][month-abbreviated][year][time][gmtoffset]
# receives an arrayref, returns a scalar (formatted string)
#
sub _to_date {
    my($date) = @_;
#TODO: This actually is incorrect, because day of week is optional
#      so may have N or N+1 parts depending on sender

#probably don't need this method, anyway, as I can use get_dttm on
#mail incoming.

    my($d) = $date->[2].' ';
#TODO: Is this right?
    $d .= $date->[1] =~ /\d\d/ ? $date->[1] : '0' . $date->[1];
    $d .= ' '.$date->[3];
    return $d;
}

# _write_mime(string club_name, string file_name, string_ref msg)
#
# Writes msg to file server.
#
sub _write_mime {
    my($club_name, $file_name, $msg) = @_;
    &_trace('writing file: $file_name') if $_TRACE;
    $_FILE_CLIENT->create('/' . $club_name . '/messages/html/'
	    . $file_name, $msg) || die("write failed: $$msg");
    return;
}

# _write_mime(string club_name, string output_file_name, string_ref hdr)
#
# Writes hdr to file server.
#
#TODO: merge with _write_mime.  Name could be passed in.
sub _write_mime_header{
    my($club_name, $output_file_name, $hdr) = @_;
#TODO: create method to create files names, instead of having this
#      concat everywhere
    $_FILE_CLIENT->create('/' . $club_name . '/messages/html/'
	    . $output_file_name . "_hdr", $hdr)
	    || die("write failed: $$hdr");
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION
v
$Id$

=cut

1;
