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

=for html <a name="_MAIL_CID_PART_URL"></a>

=head2 _MAIL_CID_PART_URL : string

The URL that's used in HTML message parts to replace "cid:<content-id>"
links. The actual content-id as appended to this constant string.

=cut

sub MAIL_CID_PART_URL {
    return 'msg-part?t=';
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
my($_MAX_SUBJECT) = Bivio::Type::Line->get_width;
my($_UNKNOWN_ADDRESS);
my($_MAIL_VOLUME) = Bivio::Type::FileVolume->MAIL;
my($_CACHE_VOLUME) = Bivio::Type::FileVolume->MAIL_CACHE;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(Bivio::Mail::Message msg, int mail_id, int date)

Creates a mail message model from a L<Bivio::Mail::Message>.
 - Validates message fields
 - Stores raw message in MAIL file volume (implicit quota check)
   by figuring out its place in a possible discussion thread
 - Decodes all MIME attachments, converts text/* parts and stores
   them in volume MAIL_CACHE

=cut

sub create {
    my($self, $msg, $mail_id, $date) = @_;
    my($req) = $self->unsafe_get_request;
    my($realm_owner) = $req->get('auth_realm')->get('owner');
    my($realm_id, $realm_name) = $realm_owner->get('realm_id', 'name');

    # Use $date if Date: field can't be parsed (now as last resort)
    my($date_time) = $msg->get_date_time() || $date || time;
    my($from_email, $from_name) = $msg->get_from;
    unless (defined($from_email)) {
	$_UNKNOWN_ADDRESS = $req->format_email(
		Bivio::Type::Email->IGNORE_PREFIX.'unknown')
		unless $_UNKNOWN_ADDRESS;
	$from_email = $_UNKNOWN_ADDRESS;
        Bivio::IO::Alert->warn("Assigning 'unknown' from_email");
    }

    defined($from_name) || ($from_name = $from_email);
    my($reply_to_email) = $msg->get_reply_to;

    my($subject) = $msg->get_head->get('subject');
    $subject = '(no subject)' unless defined($subject);
    chomp($subject);
    # Strip the name prefix out of the message, but leave the "Re:"
    $subject =~ s/^\s*((?:re:)?\s*)$realm_name:\s*/$1/i;
    $subject = substr($subject, 0, $_MAX_SUBJECT);
    my($sortable_subject) = _sortable_subject($subject, $realm_name);

    my($values) = {
	realm_id => $realm_id,
	message_id => $msg->get_message_id,
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
        rfc822_file_id => 0,
        cache_file_id => 0,
    };
    # Provide mail_id if it was passed on
    $values->{mail_id} = $mail_id if defined($mail_id);

    _attach_to_thread($msg, $values);

    # Insert into mail_t and retrieve the new mail_id sequence number
    $self->SUPER::create($values);
    $mail_id = $self->get('mail_id');

# TODO: Remove this procedure after the migration is completed
    $self->setup_club($realm_owner);

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
        content => $msg->get_rfc822,
        directory_id => $volume->get_root_directory_id($req->get('auth_id')),
        volume => $volume,
    });
    my($rfc822_id, $bytes ) = $file->get('file_id', 'bytes');

    # Convert text parts to HTML and store all parts in cache
    my($cache_id) = $self->unpack_and_cache($req, $msg->get_entity,
            $user_id, $mail_id);

    $self->update({
        rfc822_file_id => $rfc822_id,
        bytes => $bytes,
        cache_file_id => $cache_id
    });
    return;
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Delete this mail and the corresponding file_t entries.
Attach replies to the parent of this message, or, if this
mail has been a thread root, make the replies thread roots.
Returns 1 if successful, 0 otherwise.

=cut

sub delete {
    my($self) = shift;
    my($req) = $self->unsafe_get_request;
    my($properties) = $self->internal_get;

    # Is message part of a thread, but not the thread root?
    if ($properties->{thread_parent_id}) {
        # Adjust all replies to now point to our parent
        _trace('Adjusting replies to point to new parent') if $_TRACE;
        my($sth) = Bivio::SQL::Connection->execute('
                UPDATE mail_t
                SET thread_parent_id = ?
                WHERE thread_parent_id = ?',
                [$properties->{thread_parent_id}, $properties->{mail_id}]);
    }
    elsif ($properties->{is_thread_root}) {
        # Deleting the root of a thread!
        # Get the first reply and make it the new thread root
        my($sth) = Bivio::SQL::Connection->execute('
                    SELECT mail_id
                    FROM mail_t
                    WHERE thread_parent_id = ?
                    ORDER BY date_time',
                [$properties->{mail_id}]);
        my $row = $sth->fetchrow_arrayref;
        my($new_root) = $row->[0];
        if( defined($new_root) ) {
            _trace('Making ', $new_root, ' the new thread root') if $_TRACE;
            # Let all other thread members point to the new root message
            my($sth) = Bivio::SQL::Connection->execute('
                    UPDATE mail_t
                    SET thread_root_id = ?
                    WHERE thread_root_id = ?',
                    [$new_root, $properties->{mail_id}]);
            my($num_replies) = $sth->rows;
            # Make it top of the thread
            $sth = Bivio::SQL::Connection->execute('
                    UPDATE mail_t
                    SET thread_parent_id = NULL, thread_root_id = NULL,
                        is_thread_root = ?
                    WHERE mail_id = ?',
                    [$num_replies > 0, $new_root]);
        } else {
            Bivio::IO::Alert->warn('mail_id=', $properties->{mail_id},
                    ': is_thread_root was true, but had no replies!');
        }
    }
    else {
        _trace('Message not part of a thread') if $_TRACE;
    }
    my($file) = Bivio::Biz::Model::File->new($req);
    if( defined($properties->{rfc822_file_id}) ) {
        _trace('Deleting rfc822 file, id=', $properties->{rfc822_file_id}) if $_TRACE;
        # Not clear why have to load it to delete it??
        $file->load(
                file_id => $properties->{rfc822_file_id},
                volume => $_MAIL_VOLUME,
               );
        $file->delete;
    }
    if( defined($properties->{cache_file_id}) ) {
        _trace('Deleting cache file, id=', $properties->{cache_file_id}) if $_TRACE;
        $file->load(
                file_id => $properties->{cache_file_id},
                volume => $_CACHE_VOLUME,
               );
        $file->delete;
    }
    return $self->SUPER::delete(@_);
}

=for html <a name="setup_club"></a>

=head2 setup_club(Bivio::Auth::Realm realm) :

Setup necessary volumes. Only needed during the transition phase.
Can be removed afterwards because newly created clubs will have
all current volumes initialized.

=cut

sub setup_club {
    my($self, $realm_owner) = @_;
    my($req) = $self->unsafe_get_request;

    my($club_id) = $realm_owner->get('realm_id');
    my($user_id) = Bivio::Biz::Model::RealmAdminList->get_first_admin($realm_owner);

    # Initialize club's file volumes MAIL and MAIL_CACHE, if necessary
    my($v);
    for $v ($_MAIL_VOLUME, $_CACHE_VOLUME) {
        my($file) = Bivio::Biz::Model::File->new($req);
        # Try to load top-level directory for this volume
        unless( $file->unsafe_load(file_id => $v->get_root_directory_id($club_id)) ) {
            # Create top-level volume
            _trace('Initializing volume ', $v, ' for club ', $club_id,
                    ', user ', $user_id) if $_TRACE;
            $file->create_volume($club_id, $user_id, $v);
        }
    }
    return;
}

=for html <a name="unpack_and_cache"></a>

=head2 unpack_and_cache(Request req, MIME::Entity e, int user_id, int mail_id) : int

Unpack all parts recursively, convert simple text into HTML and store all
parts in cache. Returns the top-level directory id.

=cut

sub unpack_and_cache {
    my($self, $req, $entity, $user_id, $mail_id) = @_;

    # Convert and store attachments
    my($volume) = $_CACHE_VOLUME;
    my($cache_id) = _walk_attachment_tree($self, $entity,
            $volume->get_root_directory_id($req->get('auth_id')),
            $user_id, $mail_id, undef);
    return $cache_id;
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
            rfc822_file_id => ['PrimaryId', 'NOT_NULL'],
            cache_file_id => ['PrimaryId', 'NOT_NULL'],
            bytes => ['Integer', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(realm_id Club.club_id)],
	],
    };
}

#=PRIVATE METHODS

# _strip_non_mime(string header) : string
#
# Strip all non-MIME headers, returning only Content-* headers
#
sub _strip_non_mime {
    my($header) = @_;
    my($mime_header) = '';
    foreach my $l (split(/\r?\n/, $header)) {
        $l =~ /^Content\-/i && ($mime_header .= $l . "\n");
    }
    $mime_header = "Content-Type: text/plain\n" unless length($mime_header);
    return $mime_header;
}

# _walk_attachment_tree(MIME::Entity entity, int dir_id, string mail_id, int index) : int
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
    my($self, $entity, $dir_id, $user_id, $mail_id, $index) = @_;
    my($req) = $self->unsafe_get_request;
    my($file) = Bivio::Biz::Model::File->new($req);

    $entity->head->unfold;
    my($ct) = $entity->mime_type;
    my($aux_info) = _strip_non_mime($entity->header_as_string);
    my(@parts) = $entity->parts;

    # Special message/rfc822 handling, it becomes multipart (header and rest)
    # Special text/plain handling, it becomes multipart (text/plain and text/html)
    if (@parts || $ct eq 'message/rfc822') {
        # Has sub-parts, so create directory and descend
        $mail_id .= '_' . $index if $index;
        $file->create({
            is_directory => 1,
            name => $mail_id,
            user_id => $user_id,
            aux_info => $aux_info,
            directory_id => $dir_id,
            volume => $_CACHE_VOLUME,
        });
        $dir_id = $file->get('file_id');
        if( $ct eq 'message/rfc822' ) {
            # Re-parse this part as a separate mail message
            my($content) = $entity->bodyhandle->as_string;
            my($msg) = Bivio::Mail::Message->new(\$content);
            $entity = $msg->get_entity;
            $entity->head->unfold;
            # Handle the header as a separate part
            my($header) = MIME::Entity->build(Type => 'text/rfc822-headers',
                    Data => $entity->header_as_string);
            # Replace original header because we stored it separately already
            $entity->head(MIME::Head->new());
            $entity->head->replace('Content-Type', $entity->mime_type);
            @parts = ( $header, $msg->get_entity);
        }
        my($i);
        for $i (0..$#parts) {
            # For multipart/alternatives, only keep the HTML text-type part
            if( $ct eq 'multipart/alternative' &&
                    $parts[$i]->mime_type =~ m|^text/| ) {
                next unless $parts[$i]->mime_type eq 'text/html';
            }
            # Pass $mail_id and $i separately, so a subpart can refer to its parent
            _walk_attachment_tree($self, $parts[$i], $dir_id, $user_id,
                    $mail_id, sprintf('%02X', $i));
        }
    }
    else {
        # Append the given index or its content-id to the filename
        if(my($cid) = $entity->head->get('Content-ID')) {
            $cid =~ s/(^\s*<|>\s*$)//g;
            $mail_id .= '_' . $cid;
        } elsif ($index) {
            $mail_id .= '_' . $index;
        }
        my($content) = $entity->bodyhandle->as_string;
        $file->create({
            is_directory => 0,
            name => $mail_id,
            user_id => $user_id,
            # Store complete header only for sub-parts, not for single-part messages
            aux_info => $aux_info,
            content => \$content,
            directory_id => $dir_id,
            volume => $_CACHE_VOLUME,
        });
    }
    return $file->get('file_id');
}

# _attach_to_thread(Bivio::Mail::Message msg, hash_ref values) : 
#
# Find an existing thread for I<msg>, using the message-ids first
# and if that fails using the subject to match up with other messages.
#
# TODO: Test to see if this works properly
sub _attach_to_thread {
    my($msg, $values) = @_;
    # Shortcutting the procedure... only use newest message-id
# TODO: Search for all message ids
    my($in_reply_to) = $msg->get_references;
    _trace('Looking for in_reply-to ', $in_reply_to) if $in_reply_to && $_TRACE;
    if ($in_reply_to) {
        # Have existing message with message_id = $in_reply_to?
        my($sth) = Bivio::SQL::Connection->execute('
                SELECT mail_id,is_thread_root,thread_root_id
                FROM mail_t
                WHERE message_id=?',
                [$in_reply_to]);
        my($row) = $sth->fetchrow_arrayref;
        if( defined($row) ) {
            _trace('Found parent via Message-Id') if $_TRACE;
            _attach_to_parent($row, $values);
        }
    }
    unless (exists($values->{thread_parent_id})) {
        # Have message(s) with the same subject? Attach to root message
        my($sth) = Bivio::SQL::Connection->execute('
                SELECT mail_id,is_thread_root,thread_root_id
                FROM mail_t
                WHERE subject_sort = ? AND thread_root_id = NULL
                ORDER BY date_time ASC',
                [$values->{subject_sort}]);
        # Attach to oldest message
        my($row) = $sth->fetchrow_arrayref;
        if( defined($row) ) {
            _trace('Found parent via Subject') if $_TRACE;
           _attach_to_parent($row, $values);
        }
    }
    return;
}

# _attach_to_parent(Bivio::SQL::Connection sth, hash_ref values) : 
#
# Use first row returned by I<sth> as the parent message and
# update I<values> to link to it. Also mark the parent as a "thread root"
# in case it does neither have a thread_root_id nor a thread_parent_id.
#
sub _attach_to_parent {
    my($row, $values) = @_;
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
                        WHERE mail_id=?',
                [$row->[0]]);
    }
    return;
}

# _sortable_subject(string subject) : string
#
# Returns a stripped, lowercase version of the subject line for
# storing in the "subject_sort" field which is used by the database
# to sort subjects. Must ensure to not return an empty string.
#
sub _sortable_subject {
    my($subject) = @_;
    $subject = lc($subject);
    $subject =~ s/^\s*re:\s*//;
    $subject =~ s/\s+//g;
    # Handle case of empty subject
    $subject = '.' unless length($subject);
    return $subject;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
