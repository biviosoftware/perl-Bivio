# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Mail;
use strict;

$Bivio::Biz::Model::Mail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Mail - where email messages are managed

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
which is stored in mail_t and file_t, volume MAIL & MAIL_CACHE


=cut


=head1 CONSTANTS

=cut

=for html <a name="ATT_DELIMITER"></a>

=head2 ATT_DELIMITER : string

Character used to build filenames for mail attachments

=cut

sub ATT_DELIMITER {
    return '-';
}


#=IMPORTS
use MIME::Parser;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Email;
use Bivio::Type::PrimaryId;
use Bivio::Type::FileVolume;
use Bivio::MIME::TextToHTML;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_MAX_WIDTH) = Bivio::Type::Line->get_width;
my($_MAIL_VOLUME) = Bivio::Type::FileVolume->MAIL;
my($_CACHE_VOLUME) = Bivio::Type::FileVolume->MAIL_CACHE;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Bivio::Mail::Message msg, int mail_id, int date) : Bivio::Biz::Model::Mail

Creates a mail message model from a L<Bivio::Mail::Message>.
 - Validates message fields
 - Stores raw message in MAIL file volume (implicit quota check)
   by figuring out its place in a possible discussion thread
 - Decodes all MIME attachments, converts text/* parts and stores
   them in volume MAIL_CACHE

=cut

sub create {
    my($self, $msg, $mail_id, $date) = @_;
    my($req) = $self->get_request;
    my($realm_owner) = $req->get('auth_realm')->get('owner');
    my($realm_id, $realm_name) = $realm_owner->get('realm_id', 'name');

    # Use $date if Date: field can't be parsed (now as last resort)
    my($date_time) = $msg->get_date_time();
    $date_time = $date || time unless defined($date_time);

    # Need to have a From address to continue
    my($from_email, $from_name) = $msg->get_from;
    $self->throw_die('DIE', {message => 'missing or bad From: address'})
                unless defined($from_email);
    Bivio::Type::Email->invalidate(\$from_email)
                if length($from_email) > $_MAX_WIDTH;

    # Make sure from_name is is not undefined or empty
    $from_name =~ s/(^\s+|\s+$)//g if defined($from_name);
    $from_name = $from_email unless defined($from_name) && length($from_name);
    $from_name = substr($from_name, 0, $_MAX_WIDTH);

    my($reply_to_email) = $msg->get_reply_to || $from_email;
    Bivio::Type::Email->invalidate(\$reply_to_email)
                if length($reply_to_email) > $_MAX_WIDTH;

    my($subject) = $msg->get_field('subject');
    my($sortable_subject);
    ($subject, $sortable_subject) = _sortable_subject($subject, $realm_name);

    my($message_id) = substr($msg->get_message_id, 0, $_MAX_WIDTH);
    my($values) = {
	realm_id => $realm_id,
	message_id => $message_id,
	date_time => Bivio::Type::DateTime->from_unix($date_time),
	from_name => $from_name,
	from_name_sort => lc($from_name),
	from_email => $from_email,
	reply_to_email => $reply_to_email,
	subject => $subject,
	subject_sort => $sortable_subject,
        is_public => 0,
        is_thread_root => 0,
        bytes => 0,
        rfc822_file_id => undef,
        cache_file_id => undef,
    };
    # Provide mail_id if it was passed on
    $values->{mail_id} = $mail_id if defined($mail_id);

    _attach_to_thread($req, $msg, $values);

    # Insert into mail_t and retrieve the new mail_id sequence number
    $self->SUPER::create($values);
    $mail_id = $self->get('mail_id');

    my($volume) = $_MAIL_VOLUME;
    my($user_id) = $req->unsafe_get('auth_user_id');
    # Get user of root directory if we don't have an auth_user
    unless( $user_id ) {
        _trace('No user_id, inheriting it from the root directory') if $_TRACE;
        my($root_dir_id) = $volume->get_root_directory_id($req->get('auth_id'));
        my($root_dir) = Bivio::Biz::Model::File->new($req);
        $root_dir->load(file_id => $root_dir_id);
        $user_id = $root_dir->get('user_id');
    }
    # Store raw message in file_t
    my($file) = Bivio::Biz::Model::File->new($req);
    $file->create({
        is_directory => 0,
        user_id => $user_id,
        name => $mail_id,
        content => $msg->get_rfc822 || \$msg->as_string,
        directory_id => $volume->get_root_directory_id($req->get('auth_id')),
        volume => $volume,
    });
    my($rfc822_id, $bytes) = $file->get('file_id', 'bytes');

    # Convert text parts to HTML and store all parts in cache
    my($cache_id) = $self->cache_parts($req, $msg->get_entity, $user_id);

    return $self->update({
        rfc822_file_id => $rfc822_id,
        bytes => $bytes,
        cache_file_id => $cache_id
    });
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Delete this mail and the corresponding file_t entries.
Attach replies to the parent of this message, or, if this
mail has been a thread root, make the replies thread roots.
Returns 1 if successful, 0 otherwise.

TODO: Untangle this routine!

=cut

sub delete {
    my($self) = shift;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    my($mail_id) = $properties->{mail_id};
    # Is message part of a thread, but not the thread root?
    if ($properties->{thread_parent_id}) {
        # Adjust all direct replies to now point to our parent
        _trace('Adjusting replies to point to new parent') if $_TRACE;
        my($sth) = Bivio::SQL::Connection->execute('
                UPDATE mail_t
                SET thread_parent_id = ?
                WHERE realm_id = ?
                    AND thread_parent_id = ?',
                [$properties->{thread_parent_id}, $req->get('auth_id'),
                    $mail_id]);
#TODO: Check if any replies left, ie. if it's still a thread
    }
    elsif ($properties->{is_thread_root}) {
        # Deleting the root of a thread!
        # Get the first reply and make it the new thread root
        my($sth) = Bivio::SQL::Connection->execute('
                    SELECT mail_id
                    FROM mail_t
                    WHERE realm_id = ?
                        AND thread_parent_id = ?
                        ORDER BY date_time',
                [$req->get('auth_id'), $mail_id]);
        my $row = $sth->fetchrow_arrayref;
        my($new_root) = $row->[0];
        if (defined($new_root)) {
            # Adjust all direct replies to point the new parent message
            _trace('Adjusting replies to point to new parent') if $_TRACE;
            $sth = Bivio::SQL::Connection->execute('
                    UPDATE mail_t
                    SET thread_parent_id = ?
                    WHERE realm_id = ?
                        AND thread_parent_id = ?',
                    [$new_root, $req->get('auth_id'), $mail_id]);
            _trace('Making ', $new_root, ' the new thread root') if $_TRACE;
            # Let all other thread members point to the new root message
            $sth = Bivio::SQL::Connection->execute('
                    UPDATE mail_t
                    SET thread_root_id = ?
                    WHERE realm_id = ?
                        AND thread_root_id = ?',
                    [$new_root, $req->get('auth_id'), $mail_id]);
            my($is_thread_root) = $sth->rows > 1 ? 1 : 0;
            # Make it top of the thread
            $sth = Bivio::SQL::Connection->execute('
                    UPDATE mail_t
                    SET thread_parent_id = NULL, thread_root_id = NULL,
                        is_thread_root = ?
                    WHERE realm_id = ?
                        AND mail_id = ?',
                    [$is_thread_root, $req->get('auth_id'), $new_root]);
        }
    }
    else {
        _trace('Message not part of a thread') if $_TRACE;
    }

    # Need to delete the mail_t entry before deleting the files
    # because of the foreign key constraints
    return 0 unless $self->SUPER::delete(@_);

    my($file) = Bivio::Biz::Model::File->new($req);
    if (defined($properties->{rfc822_file_id})) {
        _trace('Deleting rfc822 file, id=', $properties->{rfc822_file_id})
                if $_TRACE;
        $file->delete(file_id => $properties->{rfc822_file_id},
            volume => $_MAIL_VOLUME);
    }
    if (defined($properties->{cache_file_id})) {
        _trace('Deleting cache file, id=', $properties->{cache_file_id})
                if $_TRACE;
        $file->delete(file_id => $properties->{cache_file_id},
                volume => $_CACHE_VOLUME);
    }
    return 1;
}

=for html <a name="cache_parts"></a>

=head2 cache_parts(Bivio::Agent::Request req, MIME::Entity e, int user_id) : int

Unpack all parts recursively and store in MAIL_CACHE volume.
Returns the top-level file id for the cache.

Loads raw RFC822 message from MAIL volume in case a MIME entity
is not provided. In this case, the cached parts are deleted and
recreated after reparsing the RFC822 contents.

=cut

sub cache_parts {
    my($self, $req, $entity, $user_id) = @_;
    my($properties) = $self->internal_get;

    my($volume) = $_CACHE_VOLUME;
    my($root_id) = $volume->get_root_directory_id($req->get('auth_id'));
    unless( defined($entity) ) {

        # RE-parse and RE-cache a message
        my($file) = Bivio::Biz::Model::File->new($req);
        $file->load(
                file_id => $self->get('rfc822_file_id'),
                volume => $_MAIL_VOLUME,
               );
        # Parse message
        $entity = MIME::Parser->new(output_to_core => 'ALL')
                ->parse_data($file->get('content'));

        # Allow updating the subject which possibly changed
        my($realm_name) = $req->get('auth_realm')->get('owner')->get('name');
        my($subject) = $entity->head->get('subject');
        my($sortable_subject);
        ($subject, $sortable_subject)
                = _sortable_subject($subject, $realm_name);
        $self->update({
            subject => $subject,
            subject_sort => $sortable_subject,
            bytes => $file->get('bytes'),
        });

        # Delete cache files
        my($cache_file_id) = $properties->{cache_file_id};
        if (defined($cache_file_id)) {
            # Use the root directory as a temporary file_id to keep
            # the constraint happy
            $self->update({cache_file_id => $root_id});
            $file->delete(file_id => $cache_file_id, volume => $volume);
        }
    }
    my($cache_id) = _walk_attachment_tree($self, $entity, $root_id,
            $user_id, $self->get('mail_id'), $self->get('is_public'));
    # Correct file_id in case the root directory was used temporarily
    $self->update({cache_file_id => $cache_id})
            if defined($properties->{cache_file_id});
    return $cache_id;
}

=for html <a name="get_rfc822_file"></a>

=head2 get_rfc822_file(Bivio::Agent::Request) : Bivio::Biz::Model::File

Return file with message' raw RFC822 contents

=cut

sub get_rfc822_file {
    my($self, $req) = @_;
    my($properties) = $self->internal_get;

    my($file_id) = $properties->{rfc822_file_id};
    $self->throw_die('NOT_FOUND', 'mail has no RFC822 file')
            unless defined($file_id);

    my($file) = Bivio::Biz::Model::File->new($req);
    $file->load(file_id => $file_id, volume => $_MAIL_VOLUME);
    return $file;
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
            mail_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            message_id => ['Line', 'NOT_NULL_UNIQUE'],
            date_time => ['DateTime', 'NOT_NULL'],
            from_name => ['Line', 'NOT_NULL'],
            from_name_sort => ['Line', 'NOT_NULL'],
            from_email => ['Email', 'NOT_NULL'],
            reply_to_email => ['Email', 'NONE'],
            subject => ['Line', 'NOT_NULL'],
            subject_sort => ['Line', 'NOT_NULL'],
            is_public => ['Boolean', 'NOT_NULL'],
            is_thread_root => ['Boolean', 'NOT_NULL'],
            thread_root_id => ['PrimaryId', 'NONE'],
            thread_parent_id => ['PrimaryId', 'NONE'],
            rfc822_file_id => ['PrimaryId', 'NONE'],
            cache_file_id => ['PrimaryId', 'NONE'],
            bytes => ['Integer', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(realm_id Club.club_id)],
	],
    };
}

=for html <a name="set_is_public"></a>

=head2 set_is_public(boolean is_public)

Sets the public bit in this message and all its files

=cut

sub set_is_public {
    my($self, $is_public) = @_;
    $self->update({is_public => $is_public});

    my($file) = Bivio::Biz::Model::File->new($self->get_request);
    $file->load(file_id => $self->get('rfc822_file_id'));
    $file->update({
        is_public => $is_public,
        modified_date_time => $file->get('modified_date_time'),
    });

    my($cache_file_id) = $self->get('cache_file_id');
    return unless defined($cache_file_id);
    my($realm_id) = $self->get('realm_id');
    my($fv) = $_CACHE_VOLUME->as_sql_param;
    # Change is_public flag on all cache files for this message
    my($sth) = Bivio::SQL::Connection->execute(<<'EOF',
        UPDATE file_t
        SET is_public = ?
        WHERE file_id IN
        (SELECT file_id FROM file_t
            START WITH realm_id = ?
                AND file_id = ?
                AND volume = ?
            CONNECT BY realm_id = ?
                AND PRIOR file_id = directory_id
                AND volume = ?)
EOF
                [$is_public, $realm_id, $cache_file_id, $fv,
                    $realm_id, $fv]);
    return;
}

#=PRIVATE METHODS

# _strip_non_mime(string header) : string
#
# Strip all non-MIME headers, returning only Content-* headers
#
sub _strip_non_mime {
    my($header) = @_;
    my($mime_header) = '';
    # Make sure it really is unfolded
    $header =~ s/\r?\n[ \t]+/ /gs;
    foreach my $l (split(/\r?\n/, $header)) {
        $l =~ /^Content\-/i && ($mime_header .= $l . "\n");
    }
    # Return minimal MIME information if none available
    $mime_header = "Content-Type: text/plain\n" unless length($mime_header);
    return $mime_header;
}

# _walk_attachment_tree(MIME::Entity entity, int dir_id, string user_id, string name, boolean is_public) : int
#
# Descend into the message parts:
#  - create a directory for multipart attachments
#  - create a file for each actual part
# Store the MIME header in file_t.aux_info field
# Returns file_id in case of a single part message, directory_id otherwise
#
#TODO: This routine might need a clearer structure
#
sub _walk_attachment_tree {
    my($self, $entity, $dir_id, $user_id, $name, $is_public) = @_;
    my($req) = $self->get_request;
    my($file) = Bivio::Biz::Model::File->new($req);

    $entity->head->unfold;
    my($ct) = $entity->mime_type;
    my($aux_info) = _strip_non_mime($entity->header_as_string);
    my(@parts) = $entity->parts;

    # Special message/rfc822 handling, it becomes multipart (header and rest)
    # Special text/plain handling, it becomes multipart (text/plain and text/html)
    if (@parts || $ct eq 'message/rfc822') {
        # Has sub-parts, so create directory and descend
        $file->create({
            is_directory => 1,
            name => $name,
            user_id => $user_id,
            aux_info => $aux_info,
            is_public => $is_public,
            directory_id => $dir_id,
            volume => $_CACHE_VOLUME,
        });
        $dir_id = $file->get('file_id');
        if ($ct eq 'message/rfc822') {
            # Re-parse this part as a separate mail message
            my($content) = $entity->bodyhandle->as_string;
            my($msg) = Bivio::Mail::Message->new(\$content);
            $entity = $msg->get_entity;
            # Save the real top-level content type
            my($real_ct) = $entity->mime_type;
            $entity->head->unfold;
            # Handle the header as a separate part
            my($header) = MIME::Entity->build(Type => 'text/rfc822-headers',
                    Data => $entity->header_as_string);
            # Replace original header because we stored it separately already
            $entity->head(MIME::Head->new());
            $entity->head->replace('Content-Type', $real_ct);
            @parts = ( $header, $entity);
        }
        my($i);
        foreach $i (0..$#parts) {
            # For multipart/alternatives, only keep the HTML text-type part
            if ($ct eq 'multipart/alternative' &&
                    $parts[$i]->mime_type =~ m|^text/|) {
                next unless $parts[$i]->mime_type eq 'text/html';
            }
            # Create a new base name by adding a suffix to the existing name
            _walk_attachment_tree($self, $parts[$i], $dir_id, $user_id,
                    $name . sprintf(ATT_DELIMITER().'%02x', $i), $is_public);
        }
    }
    else {
        my($content) = $entity->bodyhandle->as_string;
        $file->create({
            is_directory => 0,
            name => $name,
            user_id => $user_id,
            aux_info => $aux_info,
            is_public => $is_public,
            content => \$content,
            directory_id => $dir_id,
            volume => $_CACHE_VOLUME,
        });
    }
    return $file->get('file_id');
}

# _attach_to_thread(Bivio::Agent::Request req, Bivio::Mail::Message msg, hash_ref values)
#
# Find an existing thread for I<msg>, using the message-ids first
# and if that fails using the subject to match up with other messages.
#
# TODO: Test to see if this works properly
sub _attach_to_thread {
    my($req, $msg, $values) = @_;
    # Shortcutting the procedure... only use newest message-id
# TODO: Search for all message ids
    my($in_reply_to) = $msg->get_references;
    _trace('Looking for in_reply-to ', $in_reply_to)
	    if $_TRACE && $in_reply_to;
    if ($in_reply_to) {
        # Have existing message with message_id = $in_reply_to?
        my($sth) = Bivio::SQL::Connection->execute('
                SELECT mail_id,is_thread_root,thread_root_id
                FROM mail_t
                WHERE realm_id = ?
                    AND message_id = ?',
                [$req->get('auth_id'), $in_reply_to]);
        my($row) = $sth->fetchrow_arrayref;
        if (defined($row)) {
            _trace('Found parent via Message-Id ', $in_reply_to) if $_TRACE;
            _attach_to_parent($req, $row, $values);
        }
    }
    unless (exists($values->{thread_parent_id})) {
        # Have message(s) with the same subject?
        my($sth) = Bivio::SQL::Connection->execute('
                SELECT mail_id,is_thread_root,thread_root_id
                FROM mail_t
                WHERE realm_id = ?
                    AND subject_sort = ?
                    AND thread_root_id = NULL
                    ORDER BY date_time ASC',
                [$req->get('auth_id'), $values->{subject_sort}]);
        # Attach to oldest message
        my($row) = $sth->fetchrow_arrayref;
        if (defined($row)) {
            _trace('Found parent via Subject') if $_TRACE;
           _attach_to_parent($req, $row, $values);
        }
    }
    return;
}

# _attach_to_parent(Bivio::Agent::Request req, Bivio::SQL::Connection sth, hash_ref values) : 
#
# Use first row returned by I<sth> as the parent message and
# update I<values> to link to it. Also mark the parent as a "thread root"
# in case it does neither have a thread_root_id nor a thread_parent_id.
#
sub _attach_to_parent {
    my($req, $row, $values) = @_;
    _trace('Attaching to parent msg, id=', $row->[0]) if $_TRACE;
    # Inherit the thread_root_id from the parent
    $values->{thread_root_id} = $row->[2] || $row->[0];
    # Also link directly to the parent
    $values->{thread_parent_id} = $row->[0];
    # If the parent message does not have a thread_root_id
    # make it the root of this new thread
    unless ($row->[2]) {
        Bivio::SQL::Connection->execute('
                    UPDATE mail_t
                    SET is_thread_root = 1
                    WHERE realm_id = ?
                        AND mail_id = ?',
                [$req->get('auth_id'), $row->[0]]);
    }
    return;
}

# _sortable_subject(string subject, string realm_name) : string
#
# Returns a stripped, lowercase version of the subject line for
# storing in the "subject_sort" field which is used by the database
# to sort subjects. Must ensure to not return an empty string.
#
sub _sortable_subject {
    my($subject, $realm_name) = @_;

    if (defined($subject)) {
        chomp($subject);
        # Strip the name prefix out of the message, but leave the "Re:"
        $subject =~ s/^\s*((?:re:)?\s*)$realm_name:\s*/$1/i;
        $subject = substr($subject, 0, $_MAX_WIDTH);
    }
    $subject = '(no subject)' unless defined($subject) && length($subject);

    my($sortable) = lc($subject);
    $sortable =~ s/^\s*re:\s*//;
    $sortable =~ s/\s+//g;
    # Handle case of empty subject
    $sortable = '.' unless length($sortable);
    return ($subject, $sortable);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
