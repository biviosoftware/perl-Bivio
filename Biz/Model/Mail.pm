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
    chomp($subject);
    my($realm_id, $realm_name) = $realm_owner->get('realm_id', 'name');
    # Strip the name prefix out of the message, but leave the "Re:"
    $subject =~ s/^\s*((?:re:)?\s*)$realm_name:\s*/$1/i;
    $subject = defined($subject) && $subject !~ /^\s*$/s
	    ? substr($subject, 0, $_MAX_SUBJECT) : '(no subject)';
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
    };
    # Provide mail_id if it was passed on
    $values->{mail_id} = $mail_id if defined($mail_id);

    _attach_to_thread($msg, $values);

    # Insert into mail_t and retrieve the new mail_id sequence number
    $self->SUPER::create($values);
    $mail_id = $self->get('mail_id');

    $self->setup_club($realm_owner);

    my($volume) = Bivio::Type::FileVolume::MAIL;
    my($user_id) = $req->unsafe_get('auth_user');
    # Get user of root directory if we don't have an auth_user
    unless( $user_id ) {
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
        rfc822_id => $rfc822_id,
        bytes => $bytes,
        cache_id => $cache_id
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
    } elsif ($properties->{is_thread_root}) {
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
    my($file) = Bivio::Biz::Model::File->new($req);
    if( defined($properties->{rfc822_id}) ) {
        _trace('Deleting file, id=', $properties->{rfc822_id}) if $_TRACE;
        $file->load(
                file_id => $properties->{rfc822_id},
                volume => Bivio::Type::FileVolume::MAIL,
               );
        $file->delete;
    }
    if( defined($properties->{cache_id}) ) {
        _trace('Deleting file, id=', $properties->{cache_id}) if $_TRACE;
        $file->load(
                file_id => $properties->{cache_id},
                volume => Bivio::Type::FileVolume::MAIL_CACHE,
               );
        $file->delete;
    }
    return $self->SUPER::delete(@_);
}

=for html <a name="setup_club"></a>

=head2 setup_club(Bivio::Biz::Model::RealmOwner club) :

Setup necessary volumes

=cut

sub setup_club {
    my($self, $realm_owner) = @_;
    my($req) = $self->unsafe_get_request;

    my($club_id) = $realm_owner->get('realm_id');
    
    # Get club admin (pick first in list)
    my($admins) = Bivio::Biz::Model::RealmAdminList->new($req);
    $admins->unauth_load_all({auth_id => $club_id});
    $admins->set_cursor(0);
    my($user_id) = $admins->get('RealmUser.user_id');

    # Initialize club's file volumes MAIL and MAIL_CACHE, if necessary
    my($v);
    for $v (Bivio::Type::FileVolume::MAIL, Bivio::Type::FileVolume::MAIL_CACHE) {
        my($file) = Bivio::Biz::Model::File->new($req);
        # Try to load top-level directory for this volume
        unless( $file->unsafe_load(file_id => $v->get_root_directory_id($club_id)) ) {
            # Create top-level volume
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
    my($volume) = Bivio::Type::FileVolume::MAIL_CACHE;
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
            mail_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NONE()],
            message_id => ['Bivio::Type::Line',
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
            is_public => ['Bivio::Type::Boolean',
    		Bivio::SQL::Constraint::NONE()],
            is_inline_only => ['Bivio::Type::Boolean',
    		Bivio::SQL::Constraint::NONE()],
            is_thread_root => ['Bivio::Type::Boolean',
    		Bivio::SQL::Constraint::NONE()],
            thread_root_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NONE()],
            thread_parent_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NONE()],
            rfc822_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            cache_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            bytes => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NONE()],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(realm_id Club.club_id)],
	],
    };
}

#=PRIVATE METHODS

# _walk_attachment_tree(MIME::Entity entity, int dir_id, string mail_id, int index) : int
#
# Descend into the message parts:
#  - create a directory for multipart attachments
#  - create a file for each actual part
# Store the MIME header in file_t.aux_info field
# Returns file_id in case of a single part message, directory_id otherwise

sub _walk_attachment_tree {
    my($self, $entity, $dir_id, $user_id, $mail_id, $index) = @_;
    my($req) = $self->unsafe_get_request;
    my($file) = Bivio::Biz::Model::File->new($req);
    my(@parts) = $entity->parts;
    if (@parts) {
        # Has sub-parts, so create directory and descend
        $mail_id .= '.' . $index if $index;
        $file->create({
            is_directory => 1,
            name => $mail_id,
            user_id => $user_id,
            aux_info => $entity->header_as_string,
            directory_id => $dir_id,
            volume => Bivio::Type::FileVolume::MAIL_CACHE,
        });
        $dir_id = $file->get('directory_id');
        my($i);
        for $i (0..$#parts) {
            # Pass $mail_id and $i separately, so subparts can refer to parent
            _walk_attachment_tree($self, $parts[$i], $dir_id, $user_id,
                    $mail_id, $i);
        }
    } else {
        my($mime_type) = $entity->mime_type;
        if ($mime_type =~ m!^text/!) {
            my($tohtml) = Bivio::MIME::TextToHTML->new;
            $tohtml->convert($entity, 'att?t=' . $mail_id);
        }
        # Append the given index or its content-id to the name of the file
        if(my($cid) = $entity->head->get('Content-ID')) {
            $mail_id .= '.' . $cid;
        } elsif ($index) {
            $mail_id .= '.' . $index;
        }
        $file->create({
            is_directory => 0,
            name => $mail_id,
            user_id => $user_id,
            aux_info => $entity->mime_type,
            content => $entity->bodyhandle->as_string,
            directory_id => $dir_id,
            volume => Bivio::Type::FileVolume::MAIL_CACHE,
        });
    }
    return $file->get('file_id');
}

# _attach_to_thread(Bivio::Mail::Message msg, hash_ref values) : 
#
# Find an existing thread for I<msg>, using the message-ids first
# and if that fails using the subject to match up with other messages.
#
sub _attach_to_thread {
    my($msg, $values) = @_;
    # Shortcutting the procedure... only use newest message-id
# TODO: Search for all message ids
    my($in_reply_to) = $msg->get_references;
    if ($in_reply_to) {
        # Have existing message with message_id = $in_reply_to?
        my($sth) = Bivio::SQL::Connection->execute('
                SELECT mail_id,is_thread_root,thread_root_id FROM mail_t
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
                SELECT mail_id,is_thread_root,thread_root_id FROM mail_t
                WHERE subject_sort = ? AND thread_root_id = NULL
                ORDER BY date_time DESC',
                [$values->{subject_sort}]);
        # Attach to youngest message
        my($row) = $sth->fetchrow_arrayref;
        if( defined($row) ) {
            _trace('Found parent via subject') if $_TRACE;
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
                        WHERE message_id=?',
                [$row->[0]]);
    }
    return;
}

# _sortable_subject(string subject) : string
#
# Returns a stripped, lowercase version of the subject line for
# storing in the "subject_sort" field.
#
sub _sortable_subject {
    my($subject) = @_;
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
