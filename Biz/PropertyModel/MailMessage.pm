# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::MailMessage;


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

C<Bivio::Biz::PropertyModel::MailMessage> holds information about an email message,
the body of which is stored in the file server.

=cut

#=IMPORTS
use strict;
use MIME::Parser;
use IO::File;
use IO::Stringy;
use IO::Scalar;
use Bivio::Biz::FieldDescriptor;
use Bivio::File::Client;
use Bivio::IO::Config;
use Bivio::SQL::Support;

#=VARIABLES
my($_SQL_SUPPORT);
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});

my($_FILE_CLIENT);

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Bivio::Mail::Incoming msg, Bivio::Biz::PropertyModel::Club club)

Creates a mail message model from an L<Bivio::Mail::Incoming>.

=cut

sub create {
    my($self, $msg, $club) = @_;
    # Archive mail message first
    my($mbox) = $msg->get_unix_mailbox;
    # $dttm is always valid
    my($dttm) = $msg->get_dttm() || time;
    my($mon, $year) = (gmtime($dttm))[4,5];
    $year < 1900 && ($year += 1900);
    my($club_id, $club_name) = $club->get('club_id', 'name');

    # next, we'll want to do a file create to a subdirectory.
    # I am not sure how to check result codes to see if a directory
    # does not exist!
    
#    my $result = $_FILE_CLIENT->create('/'. $club_name . '/messages/'
#	    . sprintf("%04d%02d", $year, ++$mon), \$mbox) || die("mbox create failed: $mbox");

    $_FILE_CLIENT->append('/'. $club_name . '/mbox/'
	    . sprintf("%04d%02d", $year, ++$mon), \$mbox)
	    || die("mbox append failed: $mbox");
#TODO: Need to truncate these.  If from_email is too long, what to do?
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
#TODO: Measure real size (all unpacked files)
	'bytes' => length($body),
	'subject_sort' => &_sortable_subject($msg->get_subject( ) || '' , $club->get('name')),
	'name_sort' => &_sortable_name($from_name, $from_email)
    };
    $_SQL_SUPPORT->create($self, $self->internal_get_fields(), $values);
#TODO: Update club_t.bytes here
    my $success = $_FILE_CLIENT->create('/' . $club_name . '/messages/rfc922/'
	    . $values->{mail_message_id}, \$body)|| die("create of file failed: $body");

    # Handle email attachments. Here's a first cut...
    my $parser = new MIME::Parser(output_to_core => 'ALL');
    my $file = $msg->get_rfc822_io();   
    my $entity = $parser->read($file);
    $file->close;

    #now extract all the mime attachments
    print(STDERR "\n\nextracting MIME attachments for this mail message\n");
    my $msgid = $values->{mail_message_id};
    _extract_mime($entity, 0, $club_name, $msgid);
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
    my($property_info) = {
	'mail_message_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'club_id' => ['Internal Club ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'rfc822_id' => ['RFC822 ID',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 128)],
	'dttm' => ['Date',
		Bivio::Biz::FieldDescriptor->lookup('DATE')],
	'from_name' => ['From',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
	'from_email' => ['Email',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
	'subject' => ['Subject',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
	'bytes' => ['Number of Bytes',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 10)],
	'subject_sort' =>['Subject Sort',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
	'name_sort' =>['Name Sort',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)]
    };
    
    $_SQL_SUPPORT = Bivio::SQL::Support->new(
	    'mail_message_t', keys(%$property_info));
    return [$property_info,
	    $_SQL_SUPPORT,
	    ['mail_message_id']];
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut


#RETURNS a stripped, lowercase version of the subject line for sorting.
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

sub _sortable_name {
    my($from_name, $from_email) = @_;
    print(STDERR "_sortable_name( ) called.");
    if(!$from_name){
	die('no from_name supplied to _sortable_name');
    }
    my($str) = lc($from_name .  " <" . $from_email . ">" );
    $str =~ s/[!#$%^&*-+=]/\s/g;
    print(STDERR "stripped user name: " . $str);
    return $str;
}


#NOTE this method returns a scalar, not a reference.
#The mime header is assumed to be small.
sub _extract_mime_header($ ){
    my($entity) = @_;
    my $s;
    tie *HEADERHANDLE, 'IO::Scalar', \$s;
    my $head = $entity->head( );
    $head->print(\*HEADERHANDLE);
    return $s;
}

# NOTE this method returns a scalar reference.
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
    print(STDERR "writing file: $filename\n");
    $_FILE_CLIENT->create('/' . $clubname . '/messages/html/'
    . $filename, $msg) || die("writing of mime part failed: $$msg");
}

# This method is supposed to extract each MIME "part" of the message
# and write each one to a file named <messageid>.<index>.
# Additionally, each MIME header is written to a file: <messageid>.<index>_hdr

sub _extract_mime{
    my($entity, $fileindex, $club_name, $message_id) = @_;
    print(STDERR "extract index: $fileindex\n");
    my($numparts) = $entity->parts( ) || 0; #number of parts;
    print(STDERR "number of parts: $numparts");

#    if($fileindex > 0 ){ # then we're probably talking about sub parts. Whatever that means.
    my $mime = _extract_mime_body_decoded($entity);
    my $outputfilename = $message_id . "." . $fileindex;
    my $msg = $$mime;
    my $textplain = 0;
    my $write=1;
    my $ctype = $entity->head->get('content-type');
    my $hdr = _extract_mime_header($entity);
    print(STDERR "\ncontent type: \"$ctype\"");
    if($mime){
	if($ctype =~ /multipart\/alternative/){
	    #maybe throw away the text/plain, and just write out the HTML
	    print(STDERR "\ncontent-type is multipart/alternative. Not writing this part.");
	    $write = 0;
	}
	if($ctype =~ /multipart\/mixed/){
	    print(STDERR "\ncontent type is multipart/mixed. Not writing this part.");
	    $write = 0;
	}
	if($ctype =~ /text\/plain/){
	    $textplain = 1;
	}
	if($textplain eq(1) && $write eq(1)){ 
	    print(STDERR "\ncontent type is text/plain");
	    print(STDERR "\nwrapping with <PRE></PRE>");
	    $msg = "\n<PRE>\n" . $msg . "\n</PRE>\n";
	    _write_mime($outputfilename, $club_name, \$msg);
            _write_mime_header($club_name, $outputfilename, \$hdr);
	}
	else{ #could be text/html or some other mime type
	    print(STDERR "\ncontent-type is not text/plain. it is \"$ctype\"");
	    if($write eq(1)){
		print(STDERR "\nwriting straight through.");
		_write_mime($outputfilename, $club_name, \$msg);
		_write_mime_header($club_name, $outputfilename, \$hdr);
	    }
	}
    }

    print(STDERR "found $numparts elements. ");
    $numparts != 0 ? print(STDERR "Iterating...\n") : print(STDERR "No parts. Not iterating...\n");
    for(my $index=0; $index < $numparts; $index += 1){
	my $e = $entity->part($index);
	$fileindex = $fileindex + 1;
        _extract_mime($e, $fileindex, $club_name, $message_id);
    }
}

1;
