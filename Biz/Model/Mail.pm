# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Mail;
use strict;

$Bivio::Biz::Model::Mail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Mail - where email messages enter the system

=head1 SYNOPSIS

    use Bivio::Biz::Model::Mail;
    Bivio::Biz::Model::Mail->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Mail::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Mail> holds information about an email message
which is stored in mail_t and file_t, volume MAIL_MESSAGE&MAIL_MESSAGE_CACHE


=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Email;
use Bivio::Type::PrimaryId;
use Bivio::Type::FileVolume;
use MIME::Parser;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_MAX_SUBJECT) = Bivio::Type::Line->get_width;
my($_FILE_CLIENT);
my($_UNKNOWN_ADDRESS);

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Bivio::Mail::Message msg, Bivio::Biz::Model::RealmOwner realm_owner)

Creates a mail message model from a L<Bivio::Mail::Message>.
 - Validates message fields
 - Stores raw message in MAIL_MESSAGE file volume (implicit quota check)
   by fyguring out its place in a possible discussion thread
 - Decodes all MIME attachments, converts text/* parts and stores
   all of them in volume MAIL_MESSAGE_CACHE

=cut

sub create {
    my($self, $msg, $realm_owner) = @_;
    my($req) = $self->unsafe_get_request;

    # $date_time is always valid
    my($date_time) = $msg->get_date_time() || time;
    my($from_email, $from_name) = $msg->get_from;
    unless (defined($from_email)) {
	$_UNKNOWN_ADDRESS = $req->format_email(
		Bivio::Type::Email->IGNORE_PREFIX.'unknown')
		unless $_UNKNOWN_ADDRESS;
	$from_email = $_UNKNOWN_ADDRESS;
    }

    defined($from_name) || ($from_name = $from_email);
    my($reply_to_email) = $msg->get_reply_to;
    my($subject) = $msg->get_subject;

    my($club_id, $club_name) = $realm_owner->get('realm_id', 'name');
    # Strip the club name prefix out of the message, but leave the "Re:"
    $subject =~ s/^\s*((?:re:)?\s*)$club_name:\s*/$1/i;
    $subject = defined($subject) && $subject !~ /^\s*$/s
	    ? substr($subject, 0, $_MAX_SUBJECT) : '(no subject)';
    my($sortable_subject) = _sortable_subject($subject, $club_name);
    my($values) = {
	club_id => $club_id,
	msg_id => $msg->get_message_id,
	date_time => Bivio::Type::DateTime->from_unix($date_time),
	from_name => $from_name,
	from_name_sort => lc($from_name),
	from_email => $from_email,
	reply_to_email => $reply_to_email,
	subject => $subject,
	subject_sort => $sortable_subject,
        is_public => 0,
    };
    _trace('msg from '.$from_name.' club_id '.$club_id) if $_TRACE;
    
    # Find discussion thread and link to it
    if (@refs = $msg->get_references) {
        # SQL query...
        $values->{thread_head} = ;
        $values->{thread_parent} = ;
    }
    unless (@refs) {
        # match subject string if no success with message ids
        # SQL query...
        $values->{thread_head} = ;
        $values->{thread_parent} = ;
    }
    $self->SUPER::create($values);
    my($mail_id) = $self->get('mail_id');

    # Store raw message in file_t
    my($volume) = Bivio::Type::FileVolume::MAIL_MESSAGE;
    my($file) = Bivio::Biz::Model::File->new($req);
    $file->create({
        is_directory => 0,
        name => $mail_id,
        content => $msg->get_entity->as_string,
        directory_id => $volume->get_root_directory_id($req->get('auth_id')),
        volume => $volume,
    });
    $rfc822_id = $req->get('Bivio::Biz::Model::File.file_id');
    $self->update({ rfc822_id => $rfc822_id });

    # Preprocess text and store in cache
    $self->process_cache($mail_id, $msg->get_entity);
    
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

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_FILE_CLIENT = Bivio::File::Client->new($cfg->{file_server});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mail_t',
	columns => {
            mail_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            club_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NONE()],
            msg_id => ['Bivio::Type::Line',
    		Bivio::SQL::Constraint::NOT_NULL_UNIQUE()],
            date_time => ['Bivio::Type::DateTime',
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
            is_public => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NOT_NULL()],
            is_thread => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NOT_NULL()],
            thread_root => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            thread_parent => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            rfc822_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            cache_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => 'club_id',
	other => [
	    [qw(club_id Club.club_id)],
	],
    };
}

=for html <a name="process_cache"></a>

=head2 process_cache(int mail_id, MIME::Entity) : int

Process MIME parts, convert text into HTML and store in cache.
Return TRUE if all parts are either text, image or message parts.

=cut

sub process_cache {
    my($self, $mail_id, $entity) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Convert and store attachments
    my($volume) = Bivio::Type::FileVolume::MAIL_MESSAGE_CACHE;
    my($cache_id) = _walk_attachment_tree($self, $entity, $mail_id,
            $volume->get_root_directory_id($req->get('auth_id')));
    $self->update({ cache_id => $cache_id });

    return;
}

sub setup_club {
    my(undef, $club) = @_;
# TODO: Anything necessary?
    return;
}

#=PRIVATE METHODS

# _walk_attachment_tree(MIME::Entity entity, int dir_id, string mail_id, int index) : int
#
# Descend into the message parts:
# - create a directory for multipart attachments
# - create a file for each actual part
# Store the MIME header in file_t.aux_info field
# Returns file_id in case of a single part message, directory_id otherwise

sub _walk_attachment_tree {
    my($self, $entity, $dir_id, $mail_id, $index) = @_;
    my($file_id);
    my($req) = $self->unsafe_get_request;
    my($file) = Bivio::Biz::Model::File->new($req);
    my(@parts) = $entity->parts;
    if (@parts) {
        # Has sub-parts, so create directory and descend
        $mail_id .= '.' . $index if $index;
        $file->create({
            is_directory => 1,
            name => $mail_id,
            aux_info => $entity->head,
            directory_id => $dir_id,
            volume => Bivio::Type::FileVolume::MAIL_MESSAGE_CACHE,
        });
        $file_id = $req->get('Bivio::Biz::Model::File.file_id');
        $dir_id = $req->get('Bivio::Biz::Model::File.directory_id');
        my($i);
        for $i (0..$#parts) {
            # Pass $mail_id and $i separately, so subparts can refer to parent
            _walk_attachment_tree($self, $parts[$i], $dir_id, $mail_id, $i);
        }
    } else {
        my($mime_type) = $entity->mime_type;
        if ($mime_type =~ m!^text/!) {
            my($tohtml) = Bivio::MIME::AnyText2Html->new;
            $tohtml->convert($entity, 'att?t=' . $mail_id);
        }
        $mail_id .= '.' . $index if $index;
        $file->create({
            is_directory => 0,
            name => $mail_id,
            aux_info => $entity->header_as_string,
            content => $entity->bodyhandle->as_string,
            directory_id => $dir_id,
            volume => Bivio::Type::FileVolume::MAIL_MESSAGE_CACHE,
        });
        $file_id = $req->get('Bivio::Biz::Model::File.file_id');
    }
    return $file_id;
}

# _fileserver2db(Bivio::Biz::Model::Mail, Bivio::Agent::Request req, int mail_id) :
#
# Read a mail message from the file server and load it into
# the new mail_t/file_t system.
#
sub _fileserver2db {
    my($self, $req, $mail_id) = @_;
    my($club_name) = $req->get('auth_realm')->format_file;
    my($filename) = '/'.$club_name.'/messages/rfc822/'.$mail_id;
    my($fs_msg);
    die("couldn't get mail message: $fs_msg")
	    unless $_FILE_CLIENT->get($filename, \$fs_msg);
    my($msg) = Bivio::Mail::Message->new($fs_msg);
    my($email, $name) = $msg->get_from;
    $self->die(Bivio::DieCode::CLIENT_ERROR) unless defined($email);

    my($realm_owner) = $req->get('auth_realm')->get('owner');
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load(club_id => $realm_owner->get('realm_id'));

    my($mail) = Bivio::Biz::Model::Mail->new($req);
    $mail->create($msg, $realm_owner, $club);
    return;
}

# _sortable_subject(string subject, string clubname) : string
#
# Returns a stripped, lowercase version of the subject line for
# storing in the "subject_sort" field.
#
sub _sortable_subject {
    my($subject, $clubname) = @_;
    $subject = lc($subject);
    $subject =~ s/^\s*re:\s*//;
    $subject =~ s/\s+//g;
    return $subject;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
