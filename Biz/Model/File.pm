# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::File;
use strict;
$Bivio::Biz::Model::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::File - interface to file_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::File;
    Bivio::Biz::Model::File->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::File::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::File> is the create, read, update,
and delete interface to the C<file_t> table.

=head1 PROPERTIES

=over 4

=item aux_info

For C<FILE> volumes, this is the C<Content-Type>.  It may be null
iwc we detect the content-type (on download) from the name

=item name_sort

This is the downcased version of I<name>. It is overwritten by
L<create|"create">.  L<delete|"delete"> ignores it as well.
Use I<name> wherever possible.  However, the uniqueness constraint
is on I<name_sort>.  We emulate Windows here: case-preserving
file names.

=back

=cut

#=IMPORTS
use Bivio::Biz::Model::FileQuota;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::FileVolume;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_MAX_SQL_PARAMS) = Bivio::SQL::Connection->MAX_PARAMETERS;

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 static cascade_delete(Bivio::Biz::Model::RealmOwner realm)

Deletes all files and quota.

=cut

sub cascade_delete {
    my(undef, $realm) = @_;
    my($id) = $realm->get('realm_id');
    Bivio::SQL::Connection->execute('
            DELETE FROM file_t
            WHERE realm_id=?',
	    [$id]);
    my($fq) = Bivio::Biz::Model::FileQuota->new($realm->get_request);
    $fq->delete() if $fq->unauth_load(realm_id => $id);
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Initializes I<modified_date_time>, I<realm_id>, and
I<user_id>, if not set.  Always sets I<bytes>.  I<content>
may be C<undef>.

Sets I<directory_id> if not set to the value of
L<Bivio::Biz::Model::FilePathList::set_cursor_to_target|Bivio::Biz::Model::FilePathList/"set_cursor_to_target">.

Sets I<volume> if not set to the value of the
C<Bivio::Type::FileVolume> attribute on the request.

I<content> need not be supplied.

=cut

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;

    $self->die("directory can't have content!")
	    if $values->{is_directory} && $values->{content};

    # create_initial sets file_id, so this check will be skipped.  Others
    # don't set file_id (we hope!).
    if (!$values->{directory_id} && !$values->{file_id}) {
	my($fpl) = $self->get_request->unsafe_get(
		'Bivio::Biz::Model::FilePathList');
	$self->die('DIE', 'directory_id not set!') unless $fpl;
	$values->{directory_id} = $fpl->set_cursor_to_target;
	unless ($fpl->get('File.is_directory')) {
	    $self->die('DIE', 'no directories in file path list!')
		    unless $values->{directory_id}
			    = $fpl->get('File.directory_id');
	}
    }

    $values->{modified_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{modified_date_time};
    $values->{realm_id} = $self->get_request->get('auth_id')
	    unless $values->{realm_id};
    $values->{user_id} = $self->get_request->get('auth_user')->get('realm_id')
	    unless $values->{user_id};
    $values->{bytes} = ref($values->{content})
	    ? length(${$values->{content}}) : 0;
    $values->{name_sort} = lc($values->{name});

    # Set the volume from request if not set.
    $values->{volume} = $req->get('Bivio::Type::FileVolume')
	    unless $values->{volume};

    # Check quota first and ensures directory_id is really a directory
    _update_directory($self, $values, _kbytes($values->{bytes}));

    $self->SUPER::create($values);
    return;
}

=for html <a name="create_initial"></a>

=head2 static create_initial(Bivio::Biz::Model::RealmOwner realm, string user_id)

Creates the quota and initial file volumes.

Demo club gets smaller default quota. 

=cut

sub create_initial {
    my($proto, $realm, $user_id) = @_;
    my($req) = $realm->get_request;
    my($realm_id) = $realm->get('realm_id');

    # CReate the quota
    my($fq) = Bivio::Biz::Model::FileQuota->new($req);
    $fq->create({
	realm_id => $realm_id,
	max_kbytes => $realm->is_demo_club()
	? $fq->DEFAULT_MAX_KBYTES_FOR_DEMO_CLUB() : $fq->DEFAULT_MAX_KBYTES(),
    });

    # Create the volumes
    my($self) = $proto->new($req);
    foreach my $v (Bivio::Type::FileVolume->get_list()) {
	$self->create_volume($realm_id, $user_id, $v);
    }
    return;
}

=for html <a name="create_volume"></a>

=head2 create_volume(string realm_id, string user_id, Bivio::Type::FileVolume volume)

Creates a volume for this instance.  Should only be used for upgrades.  Use
L<create_initial|"create_initial"> to create all the volumes for a realm.

=cut

sub create_volume {
    my($self, $realm_id, $user_id, $volume) = @_;
    $self->create({
	file_id => $volume->get_root_directory_id($realm_id),
	realm_id => $realm_id,
	volume => $volume,
	directory_id => undef,
	name => $volume->get_name.$realm_id,
	user_id => $user_id,
	bytes => 0,
	is_directory => 1,
	aux_info => undef,
	content => undef,
    });
    return;
}

=for html <a name="delete"></a>

=head2 delete() : boolean

=head2 delete(hash load_args) : boolean

Deletes the file.  If it is a directory, deletes all files below.

This method assumes I<load_args> (if passed) contains the following
properties: I<bytes>, I<is_directory>, I<volume>,
except I<content>.

=cut

sub delete {
    my($self) = shift;
    my($args);
    if (@_) {
	my($req) = $self->get_request;
	$args = {@_};
	# Ensure data security by forcing realm_id to current auth_id
	$args->{realm_id} = $req->get('auth_id');
	$args->{volume} = $req->get('Bivio::Type::FileVolume')
	    unless $args->{volume};

	# Delete by name?
	if (defined($args->{name})
		&& !(defined($args->{file_id}) && defined($args->{bytes}))) {
	    # Get the name from FilePathList?
	    unless ($args->{directory_id}) {
		my($fpl) = $self->get_request->unsafe_get(
			'Bivio::Biz::Model::FilePathList');
		$self->die('DIE', 'directory_id not set!') unless $fpl;
		$args->{directory_id} = $fpl->set_cursor_to_target;
	    }

	    # Try to find the bytes and file_id
	    my($statement) = Bivio::SQL::Connection->execute(<<'EOF',
	    	SELECT file_id, bytes
		FROM file_t
		WHERE realm_id = ?
                AND volume = ?
                AND directory_id = ?
                AND name_sort = ?
EOF
		    [$args->{realm_id}, $args->{volume}->as_sql_param,
			$args->{directory_id}, lc($args->{name})]);

	    # Process result
	    my($row) = $statement->fetchrow_arrayref();
	    unless ($row) {
		# NOT_FOUND means deleted
		_trace('ignoring, not found: ', $args) if $_TRACE;
	    }
	    $args->{file_id} = $row->[0];
	    $args->{bytes} = $row->[1];
	}
	foreach my $p (qw(is_directory file_id bytes)) {
	    Carp::croak("$p: missing from load_args on File::delete")
			unless defined($args->{$p});
	}
    }
    else {
        # Make a copy, because we modify further down
	$args = {%{$self->internal_get}};
    }

    # Can't delete the root
    $self->die('NOT_FOUND', {message => 'attempt to delete file root',
	volume => $args->{volume}->get_name,
	file_id => $args->{file_id}})
	    if $args->{file_id} eq $args->{volume}->get_root_directory_id(
		    $args->{realm_id});

    my(@files) = ();
    my($kbytes) = 0;
    if ($args->{is_directory}) {
	# Find all the files that are children of this node
	# in depth-first order.
	my($statement) = Bivio::SQL::Connection->execute(<<'EOF',
	    	SELECT file_id, bytes
		FROM file_t
		WHERE realm_id = ?
                AND volume = ?
		start with file_id = ?
		CONNECT BY directory_id = PRIOR file_id
		ORDER BY LEVEL DESC
EOF
		[$args->{realm_id},
		    $args->{volume}->as_sql_param,
		    $args->{file_id}]);

	# Add in the files which this directory contains
	my($row);
	while ($row = $statement->fetchrow_arrayref()) {
	    push(@files, $row->[0]);
	    $kbytes += _kbytes($row->[1]);
	}
    }
    else {
	# Not a directory
	push(@files, $args->{file_id});
	$kbytes = _kbytes($args->{bytes});
    }

    # Delete the rows we just found.  Apparently you can't call
    # DELETE with a CONNECT BY.  Don't ask me why, I suppose she'll die. ;-)
#TODO: Move this into SQL::Connection.  Should be able to iterate over a list
    my($rows) = 0;
    while (@files) {
	my($params) = '?,' x (int(@files) > $_MAX_SQL_PARAMS
		? $_MAX_SQL_PARAMS : int(@files));
	chop($params);
	# We set volume here in case there is something really weird going on,
	# i.e. parallel deletes.
	my($sth) = Bivio::SQL::Connection->execute(<<"EOF",
	    DELETE
	    FROM file_t
	    WHERE realm_id = ?
            AND volume = ?
            AND file_id in ($params)
EOF
		[$args->{realm_id},
		    $args->{volume}->as_sql_param(),
		    splice(@files, 0, $_MAX_SQL_PARAMS)]);
	$rows += $sth->rows;
    }

    # Update the directory with the correct uid and modified_date_time.
    $args->{user_id}
	    = $self->get_request->get('auth_user')->get('realm_id');
    $args->{modified_date_time} = Bivio::Type::DateTime->now();
    _update_directory($self, $args, -$kbytes);
    return $rows ? 1 : 0;
}

=for html <a name="fixup_root_directory_name"></a>

=head2 static fixup_root_directory_name(hash_ref properties, Bivio::Agent::Request req)

Changes I<File.name> in properties to appropriate name.

Needed because the root dir name must be globally unique.

=cut

sub fixup_root_directory_name {
    my(undef, $properties, $req) = @_;
#TODO: Hack....
    my($volume) = $req->get('Bivio::Type::FileVolume');
    $properties->{'File.name_sort'}
	    = lc($properties->{'File.name'} = $volume->get_short_desc);
    return;
}

=for html <a name="get_mime_filename"></a>

=head2 get_mime_filename() : string

Treats aux_info field as a MIME header to find the (file)name specified.
Strips a leading path. Returns first occurence if found. If not, it
will create a name "download.<ext>" where <ext> matches the content-type.

Sample "aux_info" entries:

Content-Disposition: inline; filename="/tmp/nsmail38B49DB928B0262.jpeg"
Content-Disposition: inline;
 filename="ms_y2k.jpg"
Content-Type: image/gif;
        name="bivio_large.gif"
Content-Disposition: inline; filename="C:\windows\TEMP\nsmailQT.gif"

=cut

sub get_mime_filename {
    my($self) = @_;
    my($properties) = $self->internal_get;
    if( $properties->{aux_info} =~ /(file|)name="([^"]+)"/ ) {
        my($name) = $2;
        $name =~ s|.*[\\/]||;
        return $name;
    }
    else {
        # Create a name based on the Content-Type based file suffix
        # Use 'download.bin' in case the file type is unknown
        my($ct) = $self->get_mime_content_type;
        return 'download.bin' unless defined($ct);
        my($info) = Bivio::MIME::Type->get_type_info($ct);
        return 'download.bin' unless defined($info) && $info =~ /^([^,:]+)/;
        return 'download.' . $1;
    }
}

=for html <a name="get_mime_content_type"></a>

=head2 get_mime_content_type() : string

Treats aux_info field as a MIME header to find the content type.
Returns first occurence or 'text/plain' if none found.

=cut

sub get_mime_content_type {
    my($self) = @_;
    my($properties) = $self->internal_get;
    # The regexp will match newline if the Content-Type line extends over two lines
    return undef unless $properties->{aux_info} =~ /content-type:\s+([^;\n]+)/i;
    return $1;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'file_t',
	columns => {
            file_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            volume => ['FileVolume', 'NOT_ZERO_ENUM'],
            directory_id => ['PrimaryId', 'NONE'],
            name => ['FileName', 'NOT_NULL'],
            name_sort => ['FileName', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
            bytes => ['Integer', 'NOT_NULL'],
            is_directory => ['Boolean', 'NOT_NULL'],
            aux_info => ['Text', 'NONE'],
            content => ['BLOB', 'NONE'],
        },
	auth_id => [qw(realm_id)],
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values, boolean in_update_directory)

B<NOT SUPPORTED.>

=cut

sub update {
    my($self, $new_values, $in_update_directory) = @_;
    die("only works from _update_directory, sorry")
	    unless $in_update_directory;
#TODO: Need to implement update for files
#    my($properties) = $self->internal_get;
#    $new_values->{modified_date_time} = Bivio::Type::DateTime->now()
#	    unless $new_values->{modified_date_time};
#    $new_values->{user_id} =
#	    $self->get_request->get('auth_user')->get('realm_id')
#	    unless $new_values->{user_id};
#    foreach my $k (qw(bytes is_directory directory_id)) {
#	$self->die('DIE', "can't set $k in update")
#		if exists($new_values->{$k});
#    }
#    if (exists($new_values->{content})) {
#	my($c) = $new_values->{content};
#	my($bytes) = -$properties->{bytes};
#	$bytes += $new_values->{bytes} = ref($c) ? length($$c) : 0;
#    }
    $self->SUPER::update($new_values);
    return;
}

#=PRIVATE METHODS

# _kbytes(int bytes) : int
#
# Returns kbytes for bytes.  We round up from the smallest kb.
# Must be synchronized with the value in Format::Bytes.
#
sub _kbytes {
    my($bytes) = @_;
    my($kb) = int(($bytes + 1023)/1024);
    # Mininum of 1kb per file in quota.
    return $kb ? $kb : 1;
}

# _update_directory(Bivio::Biz::Model::File self, hash_ref properties, int kbytes)
#
# Adjusts FileQuota if necessary.  Updates the modified_date_time
# and user_id for directory from the properties.
#
sub _update_directory {
    my($self, $properties, $kbytes) = @_;
    my($req) = $self->get_request;

    if (defined($properties->{directory_id})) {
	my($dir) = $self->new($req);
	# Must be a directory, blows up with NOT_FOUND
	$dir->load(file_id => $properties->{directory_id},
		volume => $properties->{volume},
		is_directory => 1);
	$dir->update({modified_date_time => $properties->{modified_date_time},
	    user_id => $properties->{user_id}},
		1);
    }
    return unless $kbytes && $properties->{volume}->in_quota;

    # It is critical we try to reuse the same quota instance, because
    # multiple operations (read "replace") may occur within the same task.
    my($fq) = $req->unsafe_get('Bivio::Biz::Model::FileQuota');
    unless ($fq && $fq->get('realm_id') eq $properties->{'realm_id'}) {
	$fq = Bivio::Biz::Model::FileQuota->new($req);
	$fq->load();
    }
    $fq->update({kbytes => $fq->get('kbytes') + $kbytes});
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

